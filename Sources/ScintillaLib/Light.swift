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
    var fadeDistance: Double? { get }
}

public struct PointLight: Light {
    public var position: Point
    public var color: Color
    public var fadeDistance: Double?

    public init(position: Point, color: Color = .white, fadeDistance: Double? = nil) {
        self.position = position
        self.color = color
        self.fadeDistance = fadeDistance
    }
}

public struct AreaLight: Light {
    public var position: Point
    public var color: Color
    public var fadeDistance: Double?
    @_spi(Testing) public var corner: Point
    @_spi(Testing) public var uVec: Vector
    @_spi(Testing) public var uSteps: Int
    @_spi(Testing) public var vVec: Vector
    @_spi(Testing) public var vSteps: Int
    @_spi(Testing) public var samples: Int
    @_spi(Testing) public var jitter: Jitter

    public init(corner: Point,
                color: Color = .white,
                uVec: Vector,
                uSteps: Int,
                vVec: Vector,
                vSteps: Int,
                jitter: Jitter = RandomJitter(),
                fadeDistance: Double? = nil) {
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
        self.fadeDistance = fadeDistance
    }

    public mutating func pointAt(_ u: Int, _ v: Int) -> Point {
        return corner
            .add(uVec.multiply(Double(u) + self.jitter.next()))
            .add(vVec.multiply(Double(v) + self.jitter.next()))
    }
}
