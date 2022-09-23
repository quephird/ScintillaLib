//
//  ShapeBuilder.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/4/22.
//

import Foundation

@resultBuilder
enum ShapeBuilder {
    static func buildBlock(_ components: [Shape]...) -> [Shape] {
        return Array(components.joined())
    }

    static func buildExpression(_ expression: Shape) -> [Shape] {
        return [expression]
    }

    static func buildArray(_ components: [[Shape]]) -> [Shape] {
        return Array(components.joined())
    }
}
