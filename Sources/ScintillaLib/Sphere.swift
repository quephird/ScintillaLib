//
//  Sphere.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

@available(macOS 10.15, *)
public class Sphere: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()

    public init() {}

    @_spi(Testing) public func localIntersect(_ localRay: Ray) -> [Intersection] {
        // The vector from the sphere's center, to the ray origin
        // remember: the sphere is centered at the world origin
        let sphereToRay = localRay.origin.subtract(Point(0, 0, 0))

        let a = localRay.direction.dot(localRay.direction)
        let b = 2 * localRay.direction.dot(sphereToRay)
        let c = sphereToRay.dot(sphereToRay) - 1
        let discriminant = b*b - 4*a*c

        if discriminant < 0 {
            return []
        } else if discriminant == 0 {
            return [Intersection(-b/2/a, self)]
        } else {
            return [
                Intersection((-b - sqrt(discriminant))/2/a, self),
                Intersection((-b + sqrt(discriminant))/2/a, self)
            ]
        }
    }

    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        return localPoint.subtract(Point(0, 0, 0))
    }
}
