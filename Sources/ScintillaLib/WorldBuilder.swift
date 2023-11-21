//
//  WorldBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/15/22.
//

@available(macOS 10.15, *)
@resultBuilder
public enum WorldBuilder {
    public static func buildFinalResult(_ component: (Light, Camera, [Shape])) -> (Light, Camera, [Shape]) {
        return component
    }

    public static func buildBlock(_ light: Light, _ camera: Camera, _ shapes: [Shape]...) -> (Light, Camera, [Shape]) {
        return (light, camera, Array(shapes.joined()))
    }

    public static func buildExpression(_ light: Light) -> Light {
        return light
    }

    public static func buildExpression(_ camera: Camera) -> Camera {
        return camera
    }

    public static func buildExpression(_ shape: Shape) -> [Shape] {
        return [shape]
    }

    public static func buildBlock(_ shapes: [Shape]...) -> [Shape] {
        return Array(shapes.joined())
    }

    public static func buildArray(_ shapes: [[Shape]]) -> [Shape] {
        return Array(shapes.joined())
    }
}
