//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Light: WorldObject {
    var position: Point { get }
    var color: Color { get }
}

public struct PointLight: Light {
    public var position: Point
    public var color: Color

    public init(position: Point) {
        self.position = position
        self.color = .white
    }

    public init(position: Point, color: Color) {
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

    public init(corner: Point, uVec: Vector, uSteps: Int, vVec: Vector, vSteps: Int) {
        self.init(corner: corner,
                  color: .white,
                  uVec: uVec,
                  uSteps: uSteps,
                  vVec: vVec,
                  vSteps: vSteps,
                  jitter: RandomJitter())
    }

    public init(corner: Point, color: Color, uVec: Vector, uSteps: Int, vVec: Vector, vSteps: Int) {
        self.init(corner: corner,
                  color: color,
                  uVec: uVec,
                  uSteps: uSteps,
                  vVec: vVec,
                  vSteps: vSteps,
                  jitter: RandomJitter())
    }

    public init(corner: Point, color: Color, uVec: Vector, uSteps: Int, vVec: Vector, vSteps: Int, jitter: Jitter) {
        self.corner = corner
        self.color = color
        self.uSteps = uSteps
        self.uVec = uVec.divide(Double(uSteps))
        self.vSteps = vSteps
        self.vVec = vVec.divide(Double(vSteps))
        self.samples = uSteps * vSteps
        self.position = corner
            .add(self.uVec.multiply(Double(uSteps/2)))
            .add(self.vVec.multiply(Double(vSteps/2)))
        self.jitter = jitter
    }

    public mutating func pointAt(_ u: Int, _ v: Int) -> Point {
        return corner
            .add(uVec.multiply(Double(u) + self.jitter.next()))
            .add(vVec.multiply(Double(v) + self.jitter.next()))
    }
}
