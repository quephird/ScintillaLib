//
//  Plane.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

class Plane: Shape {
    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        if abs(localRay.direction[1]) < EPSILON {
            return []
        } else {
            let t = -localRay.origin[1] / localRay.direction[1]
            return [Intersection(t, self)]
        }
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        return vector(0, 1, 0)
    }
}
