//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Light {
    var position: Tuple4 { get set }
    var color: Color { get set }
}

public struct PointLight: Light {
    public var position: Tuple4
    public var color: Color

    public init(_ position: Tuple4) {
        self.position = position
        self.color = .white
    }

    public init(_ position: Tuple4, _ color: Color) {
        self.position = position
        self.color = color
    }
}
