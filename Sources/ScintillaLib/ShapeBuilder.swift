//
//  ShapeBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/4/22.
//

import Foundation

@resultBuilder
public enum ShapeBuilder {
    public static func buildBlock(_ components: [any Shape]...) -> [any Shape] {
        return Array(components.joined())
    }

    public static func buildExpression(_ expression: any Shape) -> [any Shape] {
        return [expression]
    }

    public static func buildArray(_ components: [[any Shape]]) -> [any Shape] {
        return Array(components.joined())
    }
}
