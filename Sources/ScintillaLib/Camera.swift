//
//  Camera.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

public struct Camera: Equatable {
    var from: Point
    var to: Point
    var up: Vector

    var horizontalSize: Int
    var verticalSize: Int
    var fieldOfView: Double
    var viewTransform: Matrix4
    var inverseViewTransform: Matrix4
    var halfWidth: Double
    var halfHeight: Double
    @_spi(Testing) public var pixelSize: Double
    public var blurEffect: BlurEffect = .none

    static func computeProperties(horizontalSize: Int,
                                  verticalSize: Int,
                                  halfView: Double) -> (Double, Double, Double) {
        let aspectRatio = Double(horizontalSize) / Double(verticalSize)
        let (halfWidth, halfHeight) = if aspectRatio >= 1 {
            (halfView, halfView/aspectRatio)
        } else {
            (halfView * aspectRatio, halfView)
        }
        let pixelSize = halfWidth * 2.0 / Double(horizontalSize)

        return (halfWidth, halfHeight, pixelSize)
    }

    public init(width horizontalSize: Int,
                height verticalSize: Int,
                viewAngle fieldOfView: Double,
                from: Point,
                to: Point,
                up: Vector) {
        self.from = from
        self.to = to
        self.up = up

        self.horizontalSize = horizontalSize
        self.verticalSize = verticalSize
        self.fieldOfView = fieldOfView

        let viewTransform = Matrix4.view(from, to, up)
        self.viewTransform = viewTransform
        self.inverseViewTransform = viewTransform.inverse()

        let (halfWidth, halfHeight, pixelSize) = Self.computeProperties(horizontalSize: horizontalSize,
                                                                        verticalSize: verticalSize,
                                                                        halfView: tan(fieldOfView/2))
        self.halfWidth = halfWidth
        self.halfHeight = halfHeight
        self.pixelSize = pixelSize
    }

    public func focalBlur(focalDistance: Double,
                          aperture: Double,
                          samples: Int) -> Self {
        var copy = self
        copy.blurEffect = .focalBlur(focalDistance, aperture, samples)

        let focalVector = to.subtract(from)
        let focalPoint = from.add(focalVector.multiply(focalDistance/focalVector.magnitude()))
        let viewTransform = Matrix4.view(from, focalPoint, up)
        copy.viewTransform = viewTransform
        copy.inverseViewTransform = viewTransform.inverse()

        let (halfWidth, halfHeight, pixelSize) = Self.computeProperties(horizontalSize: horizontalSize,
                                                                        verticalSize: verticalSize,
                                                                        halfView: focalDistance * tan(fieldOfView/2))
        copy.halfWidth = halfWidth
        copy.halfHeight = halfHeight
        copy.pixelSize = pixelSize

        return copy
    }

    public func antialiasing() -> Self {
        var copy = self
        copy.blurEffect = .antialiasing

        let viewTransform = Matrix4.view(copy.from, copy.to, copy.up)
        copy.viewTransform = viewTransform
        copy.inverseViewTransform = viewTransform.inverse()

        let (halfWidth, halfHeight, pixelSize) = Self.computeProperties(horizontalSize: horizontalSize,
                                                                        verticalSize: verticalSize,
                                                                        halfView: tan(fieldOfView/2))
        copy.halfWidth = halfWidth
        copy.halfHeight = halfHeight
        copy.pixelSize = pixelSize

        return copy
    }

    @_spi(Testing) public func rayForPixel(_ x: Int,
                                           _ y: Int,
                                           _ pixelDx: Double = 0.5,
                                           _ pixelDy: Double = 0.5,
                                           _ originDx: Double = 0.0,
                                           _ originDy: Double = 0.0) -> Ray {
        // The offset from the edge of the canvas to the pixel's center
        let offsetX = (Double(x) + pixelDx) * self.pixelSize
        let offsetY = (Double(y) + pixelDy) * self.pixelSize

        // The untransformed coordinates of the pixel in world space.
        // (Remember that the camera looks toward -z, so +x is to the *left*.)
        let worldX = self.halfWidth - offsetX
        let worldY = self.halfHeight - offsetY

        // Using the camera matrix, transform the canvas point and the origin,
        // and then compute the ray's direction vector.
        // (Remember that the canvas is at z=-1)
        let worldZ: Double = switch self.blurEffect {
        case .focalBlur(let focalDistance, _, _):
            -focalDistance
        default:
            -1
        }

        let pixel = self.inverseViewTransform.multiply(Point(worldX, worldY, worldZ))
        let origin = self.inverseViewTransform.multiply(Point(originDx, originDy, 0))
        let direction = pixel.subtract(origin).normalize()

        return Ray(origin, direction)
    }

    public func raysForPixel(x: Int, y: Int) -> [Ray] {
        switch self.blurEffect {
        case .focalBlur(_, let aperture, let samples):
            let originDeltas: [(Double, Double)] = (0..<samples).map { _ in
                let randomRadius = Double.random(in: 0..<aperture)
                let randomAngle = Double.random(in: 0..<2*PI)
                let originDx = cos(randomAngle) * randomRadius
                let originDy = sin(randomAngle) * randomRadius
                return (originDx, originDy)
            }

            let rays = originDeltas.map { (originDx, originDy) in
                let pixelDx = Double.random(in: 0.0...1.0)
                let pixelDy = Double.random(in: 0.0...1.0)
                let ray = self.rayForPixel(x, y, pixelDx, pixelDy, originDx, originDy)
                return ray
            }

            return rays
        case .antialiasing:
            let pixelDeltas = [0, 1, 2, 3].map { i in
                [0, 1, 2, 3].map { j in
                    let jitterX = Double.random(in: 0.0...0.25)
                    let jitterY = Double.random(in: 0.0...0.25)
                    let dx = Double(i)*0.25 + jitterX
                    let dy = Double(j)*0.25 + jitterY
                    return (dx, dy)
                }
            }.flatMap{ $0 }

            let rays = pixelDeltas.map { (pixelDx, pixelDy) in
                let ray = self.rayForPixel(x, y, pixelDx, pixelDy)
                return ray
            }

            return rays
        default:
            let ray = self.rayForPixel(x, y)
            return [ray]
        }
    }

    public static func == (lhs: Camera, rhs: Camera) -> Bool {
        return (lhs.horizontalSize == rhs.horizontalSize) &&
               (lhs.verticalSize == rhs.verticalSize) &&
               (lhs.fieldOfView == rhs.fieldOfView) &&
               (lhs.viewTransform == rhs.viewTransform) &&
               (lhs.inverseViewTransform == rhs.inverseViewTransform) &&
               (lhs.halfWidth == rhs.halfWidth) &&
               (lhs.halfHeight == rhs.halfHeight) &&
               (lhs.blurEffect == rhs.blurEffect)
    }
}
