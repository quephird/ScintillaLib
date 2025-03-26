//
//  SpotLight.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 3/26/25.
//

public struct SpotLight: Light, Equatable {
    public var position: Point
    public var pointAt: Point
    public var beamAngle: Double
    public var color: Color
    public var fadeDistance: Double?

    public init(position: Point,
                pointAt: Point,
                beamAngle: Double,
                color: Color = .white,
                fadeDistance: Double? = nil) {
        self.position = position
        self.pointAt = pointAt
        self.beamAngle = beamAngle
        self.color = color
        self.fadeDistance = fadeDistance
    }

    lazy public var direction: Vector = pointAt.subtract(position).normalize()

    public static func == (lhs: SpotLight, rhs: SpotLight) -> Bool {
        return (lhs.position == rhs.position) &&
               (lhs.pointAt == rhs.pointAt) &&
               (lhs.beamAngle == rhs.beamAngle) &&
               (lhs.color == rhs.color) &&
               (lhs.fadeDistance == rhs.fadeDistance)
    }
}
