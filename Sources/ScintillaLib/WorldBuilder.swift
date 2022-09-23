//
//  WorldBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/15/22.
//

@resultBuilder
public enum WorldBuilder {
    static func buildBlock(_ light: Light, _ camera: Camera, _ shapes: [Shape]...) -> (Light, Camera, [Shape]) {
        return (light, camera, Array(shapes.joined()))
    }

    static func buildExpression(_ light: Light) -> Light {
        return light
    }

    static func buildExpression(_ camera: Camera) -> Camera {
        return camera
    }

    static func buildExpression(_ shape: Shape) -> [Shape] {
        return [shape]
    }

    static func buildBlock(_ shapes: [Shape]...) -> [Shape] {
        return Array(shapes.joined())
    }

    static func buildArray(_ shapes: [[Shape]]) -> [Shape] {
        return Array(shapes.joined())
    }
}
