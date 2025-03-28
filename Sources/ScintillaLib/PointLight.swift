//
//  PointLight.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 3/28/25.
//

public struct PointLight: Light, Equatable {
    public var position: Point
    public var color: Color
    public var fadeDistance: Double?

    public init(position: Point, color: Color = .white, fadeDistance: Double? = nil) {
        self.position = position
        self.color = color
        self.fadeDistance = fadeDistance
    }

    public static func == (lhs: PointLight, rhs: PointLight) -> Bool {
        return (lhs.position == rhs.position) &&
               (lhs.color == rhs.color) &&
               (lhs.fadeDistance == rhs.fadeDistance)
    }
}
