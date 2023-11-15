//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Light {
    var position: Point { get }
    var color: Color { get }
}

public struct PointLight: Light {
    public var position: Point
    public var color: Color

    public init(_ position: Point) {
        self.position = position
        self.color = .white
    }

    public init(_ position: Point, _ color: Color) {
        self.position = position
        self.color = color
    }
}

public struct AreaLight: Light {
    public var position: Point
    public var color: Color
    @_spi(Testing) public var corner: Point
    @_spi(Testing) public var uVec: Vector
    @_spi(Testing) public var uSteps: Int
    @_spi(Testing) public var vVec: Vector
    @_spi(Testing) public var vSteps: Int
    @_spi(Testing) public var samples: Int
    @_spi(Testing) public var jitter: Jitter

    public init(_ corner: Point, _ fullUVec: Vector, _ uSteps: Int, _ fullVVec: Vector, _ vSteps: Int) {
        self.init(corner, .white, fullUVec, uSteps, fullVVec, vSteps, RandomJitter())
    }

    public init(_ corner: Point, _ color: Color, _ fullUVec: Vector, _ uSteps: Int, _ fullVVec: Vector, _ vSteps: Int) {
        self.init(corner, color, fullUVec, uSteps, fullVVec, vSteps, RandomJitter())
    }

    public init(_ corner: Point, _ color: Color, _ fullUVec: Vector, _ uSteps: Int, _ fullVVec: Vector, _ vSteps: Int, _ jitter: Jitter) {
        self.corner = corner
        self.color = color
        self.uSteps = uSteps
        self.uVec = fullUVec.divide(Double(uSteps))
        self.vSteps = vSteps
        self.vVec = fullVVec.divide(Double(vSteps))
        self.samples = uSteps * vSteps
        self.position = corner
            .add(uVec.multiply(Double(uSteps/2)))
            .add(vVec.multiply(Double(vSteps/2)))
        self.jitter = jitter
    }

    public mutating func pointAt(_ u: Int, _ v: Int) -> Point {
        return corner
            .add(uVec.multiply(Double(u) + self.jitter.next()))
            .add(vVec.multiply(Double(v) + self.jitter.next()))
    }
}
