//
//  ShapeBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/4/22.
//

import Foundation

@available(macOS 10.15, *)
@resultBuilder
public enum ShapeBuilder {
    public static func buildBlock(_ components: [Shape]...) -> [Shape] {
        return Array(components.joined())
    }

    public static func buildExpression(_ expression: Shape) -> [Shape] {
        return [expression]
    }

    public static func buildArray(_ components: [[Shape]]) -> [Shape] {
        return Array(components.joined())
    }
}
