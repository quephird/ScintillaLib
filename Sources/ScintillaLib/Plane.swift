//
//  Plane.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

public class Plane: Shape {
    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        if abs(localRay.direction[1]) < EPSILON {
            return []
        } else {
            let t = -localRay.origin[1] / localRay.direction[1]
            return [Intersection(t, self)]
        }
    }

    @_spi(Testing) public override func localNormal(_ localPoint: Point) -> Vector {
        return Vector(0, 1, 0)
    }
}
