//
//  Cone.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/28/21.
//

import Foundation

public class Cone: Shape {
    var minimum: Double
    var maximum: Double
    var isCapped: Bool

    public override init() {
        self.minimum = -.infinity
        self.maximum = .infinity
        self.isCapped = false
        super.init()
    }

    public init(_ minimum: Double, _ maximum: Double) {
        self.minimum = minimum
        self.maximum = maximum
        self.isCapped = false
    }

    public init(_ minimum: Double, _ maximum: Double, _ isCapped: Bool) {
        self.minimum = minimum
        self.maximum = maximum
        self.isCapped = isCapped
    }

    // A helper function to reduce duplication.
    // checks to see if the intersection at `t` is within a radius of y
    func checkCap(_ localRay: Ray, _ t: Double, _ y: Double) -> Bool {
        let x = localRay.origin[0] + t * localRay.direction[0]
        let z = localRay.origin[2] + t * localRay.direction[2]
        return (x*x + z*z) <= abs(y)
    }

    func localIntersectCaps(_ localRay: Ray) -> [Intersection] {
        var capIntersections: [Intersection] = []

        // Caps only matter if the cylinder is closed, and might possibly be
        // intersected by the ray.
        if !self.isCapped || localRay.direction[1] == 0 {
            return []
        }

        // Check for an intersection with the lower end cap by intersecting
        // the ray with the plane at y equal cone minimum
        let t0 = (self.minimum - localRay.origin[1]) / localRay.direction[1]
        if checkCap(localRay, t0, self.minimum) {
            capIntersections.append(Intersection(t0, self))
        }

        // Check for an intersection with the upper end cap by intersecting
        // the ray with the plane at y equal cone maximum
        let t1 = (self.maximum - localRay.origin[1]) / localRay.direction[1]
        if checkCap(localRay, t1, self.maximum) {
            capIntersections.append(Intersection(t1, self))
        }

        return capIntersections
    }

    func localIntersectWall(_ localRay: Ray) -> [Intersection] {
        let a =
            localRay.direction[0]*localRay.direction[0] -
            localRay.direction[1]*localRay.direction[1] +
            localRay.direction[2]*localRay.direction[2]
        let b =
            2 * localRay.origin[0]*localRay.direction[0] -
            2 * localRay.origin[1]*localRay.direction[1] +
            2 * localRay.origin[2]*localRay.direction[2]
        let c =
            localRay.origin[0]*localRay.origin[0] -
            localRay.origin[1]*localRay.origin[1] +
            localRay.origin[2]*localRay.origin[2]

        if a.isAlmostEqual(0.0) && b.isAlmostEqual(0){
            // Ray is parallel to the y axis
            return []
        } else if a.isAlmostEqual(0) {
            return [Intersection(-c/2/b, self)]
        } else {
            let discriminant = b*b - 4*a*c

            if discriminant < 0 {
                // Ray does not intersect the cylinder
                return []
            } else if discriminant == 0 {
                // Ray is tangent to cylinder
                let t = -b/2/a
                return [Intersection(t, self)]
            } else {
                // Ray potentially intersects cylinder twice
                var intersections: [Intersection] = []

                let t0 = (-b - sqrt(discriminant)) / (2.0 * a)
                let y0 = localRay.origin[1] + t0*localRay.direction[1]
                if self.minimum < y0 && y0 < self.maximum {
                    intersections.append(Intersection(t0, self))
                }

                let t1 = (-b + sqrt(discriminant)) / (2.0 * a)
                let y1 = localRay.origin[1] + t1*localRay.direction[1]
                if self.minimum < y1 && y1 < self.maximum {
                    intersections.append(Intersection(t1, self))
                }

                return intersections
            }
        }
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        var allIntersections: [Intersection] = []
        let wallIntersections = self.localIntersectWall(localRay)
        let capIntersections = self.localIntersectCaps(localRay)

        allIntersections.append(contentsOf: wallIntersections)
        allIntersections.append(contentsOf: capIntersections)
        allIntersections.sort { i1, i2 in
            i1.t <= i2.t
        }

        return allIntersections
    }

    override func localNormal(_ localPoint: Point, _ uv: UV) -> Vector {
        // Compute the square of the distance from the y axis
        let distance = localPoint[0]*localPoint[0] + localPoint[2]*localPoint[2]
        if distance < 1 && localPoint[1] >= self.maximum - EPSILON {
            return Vector(0, 1, 0)
        } else if distance < 1 && localPoint[1] <= self.minimum + EPSILON {
            return Vector(0, -1, 0)
        } else {
            var normalY = sqrt(localPoint[0]*localPoint[0] + localPoint[2]*localPoint[2])
            if localPoint[1] > 0 {
                normalY = -normalY
            }
            return Vector(localPoint[0], normalY, localPoint[2])
        }
    }
}
