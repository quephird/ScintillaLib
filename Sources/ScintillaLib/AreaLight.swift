//
//  AreaLight.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 3/28/25.
//

public struct AreaLight: Light, Equatable {
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

    public static func == (lhs: AreaLight, rhs: AreaLight) -> Bool {
        return (lhs.position == rhs.position) &&
               (lhs.color == rhs.color) &&
               (lhs.fadeDistance == rhs.fadeDistance) &&
               (lhs.corner == rhs.corner) &&
               (lhs.uVec == rhs.uVec) &&
               (lhs.uSteps == rhs.uSteps) &&
               (lhs.vVec == rhs.vVec) &&
               (lhs.vSteps == rhs.vSteps) &&
               (lhs.samples == rhs.samples)
    }

    public mutating func pointAt(_ u: Int, _ v: Int) -> Point {
        return corner
            .add(uVec.multiply(Double(u) + self.jitter.next()))
            .add(vVec.multiply(Double(v) + self.jitter.next()))
    }
}
