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
    var antialiasing: Bool
    public var focalBlur: FocalBlur?

    public init(width horizontalSize: Int,
                height verticalSize: Int,
                viewAngle fieldOfView: Double,
                from: Point,
                to: Point,
                up: Vector,
                antialiasing: Bool = false) {
        self.from = from
        self.to = to
        self.up = up
        let viewTransform = Matrix4.view(from, to, up)

        self.horizontalSize = horizontalSize
        self.verticalSize = verticalSize
        self.fieldOfView = fieldOfView
        self.viewTransform = viewTransform
        self.inverseViewTransform = viewTransform.inverse()

        let halfView = tan(fieldOfView/2)
        let aspectRatio = Double(horizontalSize) / Double(verticalSize)
        var halfWidth: Double
        var halfHeight: Double
        if aspectRatio >= 1 {
            halfWidth = halfView
            halfHeight = halfView / aspectRatio
        } else {
            halfWidth = halfView * aspectRatio
            halfHeight = halfView
        }
        let pixelSize = halfWidth * 2.0 / Double(horizontalSize)

        self.halfWidth = halfWidth
        self.halfHeight = halfHeight
        self.pixelSize = pixelSize
        self.antialiasing = antialiasing
    }

    public func focalBlur(_ focalBlur: FocalBlur) -> Self {
        var copy = self
        copy.focalBlur = focalBlur

        let focalVector = to.subtract(from)
        let focalPoint = from.add(focalVector.multiply(focalBlur.focalDistance/focalVector.magnitude()))
        let viewTransform = Matrix4.view(from, focalPoint, up)

        copy.viewTransform = viewTransform
        copy.inverseViewTransform = viewTransform.inverse()

        let halfView = focalBlur.focalDistance * tan(self.fieldOfView/2)
        let aspectRatio = Double(self.horizontalSize) / Double(self.verticalSize)
        var halfWidth: Double
        var halfHeight: Double
        if aspectRatio >= 1 {
            halfWidth = halfView
            halfHeight = halfView / aspectRatio
        } else {
            halfWidth = halfView * aspectRatio
            halfHeight = halfView
        }
        let pixelSize = halfWidth * 2.0 / Double(horizontalSize)

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
        let worldZ: Double
        if let focalBlur = self.focalBlur {
            worldZ = -focalBlur.focalDistance
        } else {
            worldZ = -1
        }
        let pixel = self.inverseViewTransform.multiply(Point(worldX, worldY, worldZ))
        let origin = self.inverseViewTransform.multiply(Point(originDx, originDy, 0))
        let direction = pixel.subtract(origin).normalize()

        return Ray(origin, direction)
    }

    public func raysForPixel(x: Int, y: Int) -> [Ray] {
        if let focalBlur = self.focalBlur {
            let originDeltas: [(Double, Double)] = (0..<focalBlur.samples).map { _ in
                let randomRadius = Double.random(in: 0..<focalBlur.aperture)
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
        } else if self.antialiasing {
            // NOTA BENE: The number of samples for each dimension is hardcoded below
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
        } else {
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
               (lhs.antialiasing == rhs.antialiasing) &&
               (lhs.focalBlur == rhs.focalBlur)
    }
}
