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
//        self.init(width: horizontalSize,
//                  height: verticalSize,
//                  viewAngle: fieldOfView,
//                  viewTransform: viewTransform,
//                  antialiasing: antialiasing)

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

//    public init(width horizontalSize: Int,
//                height verticalSize: Int,
//                viewAngle fieldOfView: Double,
//                viewTransform: Matrix4,
//                antialiasing: Bool = false) {
//        self.horizontalSize = horizontalSize
//        self.verticalSize = verticalSize
//        self.fieldOfView = fieldOfView
//        self.viewTransform = viewTransform
//        self.inverseViewTransform = viewTransform.inverse()
//
//        let halfView = tan(fieldOfView/2)
//        let aspectRatio = Double(horizontalSize) / Double(verticalSize)
//        var halfWidth: Double
//        var halfHeight: Double
//        if aspectRatio >= 1 {
//            halfWidth = halfView
//            halfHeight = halfView / aspectRatio
//        } else {
//            halfWidth = halfView * aspectRatio
//            halfHeight = halfView
//        }
//        let pixelSize = halfWidth * 2.0 / Double(horizontalSize)
//
//        self.halfWidth = halfWidth
//        self.halfHeight = halfHeight
//        self.pixelSize = pixelSize
//        self.antialiasing = antialiasing
//    }

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
