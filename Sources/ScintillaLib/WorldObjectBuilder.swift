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

    public static func buildExpression(_ expression: WorldObject) -> [WorldObject] {
        return [expression]
    }

    public static func buildArray(_ components: [[WorldObject]]) -> [WorldObject] {
        return Array(components.joined())
    }
}
