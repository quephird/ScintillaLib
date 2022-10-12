//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Light {
    var position: Tuple4 { get }
    var color: Color { get }
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

public struct AreaLight: Light {
    public var corner: Tuple4
    public var color: Color
    public var uVec: Tuple4
    public var uSteps: Int
    public var vVec: Tuple4
    public var vSteps: Int
    public var position: Tuple4
    public var samples: Int
    public var jitter: Jitter

    public init(_ corner: Tuple4, _ fullUVec: Tuple4, _ uSteps: Int, _ fullVVec: Tuple4, _ vSteps: Int) {
        self.init(corner, .white, fullUVec, uSteps, fullVVec, vSteps, RandomJitter())
    }

    public init(_ corner: Tuple4, _ color: Color, _ fullUVec: Tuple4, _ uSteps: Int, _ fullVVec: Tuple4, _ vSteps: Int) {
        self.init(corner, color, fullUVec, uSteps, fullVVec, vSteps, RandomJitter())
    }

    public init(_ corner: Tuple4, _ color: Color, _ fullUVec: Tuple4, _ uSteps: Int, _ fullVVec: Tuple4, _ vSteps: Int, _ jitter: Jitter) {
        self.corner = corner
        self.color = color
        self.uSteps = uSteps
        self.uVec = fullUVec.divideScalar(Double(uSteps))
        self.vSteps = vSteps
        self.vVec = fullVVec.divideScalar(Double(vSteps))
        self.samples = uSteps * vSteps
        self.position = corner
            .add(uVec.multiplyScalar(Double(uSteps/2)))
            .add(vVec.multiplyScalar(Double(vSteps/2)))
        self.jitter = jitter
    }

    public mutating func pointAt(_ u: Int, _ v: Int) -> Tuple4 {
        return corner
            .add(uVec.multiplyScalar(Double(u) + self.jitter.next()))
            .add(vVec.multiplyScalar(Double(v) + self.jitter.next()))
    }
}
