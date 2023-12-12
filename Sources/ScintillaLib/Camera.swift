//
//  Camera.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

public actor Camera {
    var horizontalSize: Int
    var verticalSize: Int
    var fieldOfView: Double
    var viewTransform: Matrix4
    var inverseViewTransform: Matrix4
    var halfWidth: Double
    var halfHeight: Double
    @_spi(Testing) public var pixelSize: Double
    var antialiasing: Bool
    var totalPixels: Int

    public init(width horizontalSize: Int,
                height verticalSize: Int,
                viewAngle fieldOfView: Double,
                from: Point,
                to: Point,
                up: Vector,
                antialiasing: Bool = false) {
        let viewTransform = Matrix4.view(from, to, up)
        self.init(width: horizontalSize,
                  height: verticalSize,
                  viewAngle: fieldOfView,
                  viewTransform: viewTransform,
                  antialiasing: antialiasing)
    }

    public init(width horizontalSize: Int,
                height verticalSize: Int,
                viewAngle fieldOfView: Double,
                viewTransform: Matrix4,
                antialiasing: Bool = false) {
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

        self.totalPixels = horizontalSize * verticalSize
    }

    @_spi(Testing) public func rayForPixel(_ pixelX: Int, _ pixelY: Int, _ dx: Double = 0.5, _ dy: Double = 0.5) -> Ray {
        // The offset from the edge of the canvas to the pixel's center
        let offsetX = (Double(pixelX) + dx) * self.pixelSize
        let offsetY = (Double(pixelY) + dy) * self.pixelSize

        // The untransformed coordinates of the pixel in world space.
        // (Remember that the camera looks toward -z, so +x is to the *left*.)
        let worldX = self.halfWidth - offsetX
        let worldY = self.halfHeight - offsetY

        // Using the camera matrix, transform the canvas point and the origin,
        // and then compute the ray's direction vector.
        // (Remember that the canvas is at z=-1)
        let pixel = self.inverseViewTransform.multiply(Point(worldX, worldY, -1))
        let origin = self.inverseViewTransform.multiply(Point(0, 0, 0))
        let direction = pixel.subtract(origin).normalize()

        return Ray(origin, direction)
    }

    private func sendProgress(newPercentRendered: Double,
                              newElapsedTime: Range<Date>,
                              to updateClosure: @MainActor @escaping (Double, Range<Date>) -> Void) {
        Task {
            await updateClosure(newPercentRendered, newElapsedTime)
        }
    }

    public func render(world: World,
                       updateClosure: @MainActor @escaping (Double, Range<Date>) -> Void) async -> Canvas {
        var renderedPixels = 0
        var percentRendered = 0.0
        let startingTime = Date()
        sendProgress(newPercentRendered: percentRendered,
                     newElapsedTime: startingTime..<startingTime,
                     to: updateClosure)
        var canvas = Canvas(self.horizontalSize, self.verticalSize)
        for y in 0..<self.verticalSize {
            for x in 0..<self.horizontalSize {
                let color: Color

                if self.antialiasing {
                    let subpixelSamplesX = 4
                    let subpixelSamplesY = 4

                    var colorSamples: Color = .black
                    for i in 0..<subpixelSamplesX {
                        for j in 0..<subpixelSamplesY {
                            let subpixelWidth = 1.0/Double(subpixelSamplesX)
                            let subpixelHeight = 1.0/Double(subpixelSamplesY)
                            let jitterX = Double.random(in: 0.0...subpixelWidth)
                            let jitterY = Double.random(in: 0.0...subpixelHeight)
                            let dx = Double(i)*subpixelWidth + jitterX
                            let dy = Double(j)*subpixelHeight + jitterY
                            let ray = self.rayForPixel(x, y, dx, dy)
                            let colorSample = world.colorAt(ray, MAX_RECURSIVE_CALLS)
                            colorSamples = colorSamples.add(colorSample)
                        }
                    }

                    let totalSamples = subpixelSamplesX*subpixelSamplesX
                    color = colorSamples.divideScalar(Double(totalSamples))
                } else {
                    let ray = self.rayForPixel(x, y)
                    color = world.colorAt(ray, MAX_RECURSIVE_CALLS)
                }
                canvas.setPixel(x, y, color)
                renderedPixels += 1
            }
            percentRendered = Double(renderedPixels)/Double(self.totalPixels)
            sendProgress(newPercentRendered: percentRendered,
                         newElapsedTime: startingTime ..< Date(),
                         to: updateClosure)
        }
        return canvas
    }
}
