//
//  Plane.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

public struct Plane: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()

    public init() {}

    @_spi(Testing) public func localIntersect(_ localRay: Ray) -> [Intersection] {
        if abs(localRay.direction[1]) < EPSILON {
            return []
        } else {
            let t = -localRay.origin[1] / localRay.direction[1]
            return [Intersection(t, self)]
        }
    }

    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        return Vector(0, 1, 0)
    }
}
