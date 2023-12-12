//
//  WorldBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/15/22.
//

@resultBuilder
public enum WorldBuilder {
    public static func buildFinalResult(_ world: [WorldObject]) -> [WorldObject] {
        return world
    }

    public static func buildExpression(_ light: Light) -> [WorldObject] {
        return [.light(light)]
    }

    public static func buildExpression(_ shape: Shape) -> [WorldObject] {
        return [.shape(shape)]
    }

    public static func buildBlock(_ objects: [WorldObject]...) -> [WorldObject] {
        return Array(objects.joined())
    }

    public static func buildArray(_ objects: [[WorldObject]]) -> [WorldObject] {
        return Array(objects.joined())
    }
}
