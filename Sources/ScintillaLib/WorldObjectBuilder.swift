//
//  WorldObjectBuilder.swift
//
//
//  Created by Danielle Kefford on 11/27/23.
//

import Foundation

@resultBuilder
public enum WorldObjectBuilder {
    public static func buildBlock(_ components: [WorldObject]...) -> [WorldObject] {
        return Array(components.joined())
    }

    public static func buildExpression(_ light: Light) -> [WorldObject] {
        return [.light(light)]
    }

    public static func buildExpression(_ shape: any Shape) -> [WorldObject] {
        return [.shape(shape)]
    }

    public static func buildArray(_ components: [[WorldObject]]) -> [WorldObject] {
        return Array(components.joined())
    }
}
