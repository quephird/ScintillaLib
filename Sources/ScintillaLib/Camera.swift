//
//  Camera.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

public struct Camera {
    var horizontalSize: Int
    var verticalSize: Int
    var fieldOfView: Double
    var viewTransform: Matrix4
    var inverseViewTransform: Matrix4
    var halfWidth: Double
    var halfHeight: Double
    var pixelSize: Double

    public init(_ horizontalSize: Int,
                _ verticalSize: Int,
                _ fieldOfView: Double,
                _ from: Point,
                _ to: Point,
                _ up: Vector) {
        let viewTransform = Matrix4.view(from, to, up)
        self.init(horizontalSize, verticalSize, fieldOfView, viewTransform)
    }

    public init(_ horizontalSize: Int, _ verticalSize: Int, _ fieldOfView: Double, _ viewTransform: Matrix4) {
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
    }
}
