//
//  WorldBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/15/22.
//

@resultBuilder
public enum WorldBuilder {
    public static func buildFinalResult(_ world: (Camera, [WorldObject])) -> (Camera, [WorldObject]) {
        return world
    }

    public static func buildBlock(_ camera: Camera, _ objects: [WorldObject]...) -> (Camera, [WorldObject]) {
        return (camera, Array(objects.joined()))
    }

    public static func buildExpression(_ camera: Camera) -> Camera {
        return camera
    }

    public static func buildExpression(_ light: Light) -> [WorldObject] {
        return [.light(light)]
    }

    public static func buildExpression(_ shape: any Shape) -> [WorldObject] {
        return [.shape(shape)]
    }

    public static func buildBlock(_ objects: [WorldObject]...) -> [WorldObject] {
        return Array(objects.joined())
    }

    public static func buildArray(_ objects: [[WorldObject]]) -> [WorldObject] {
        return Array(objects.joined())
    }
}
