//
//  Intersection.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct Intersection {
    var t: Double
    var shape: Shape

    init(_ t: Double, _ shape: Shape) {
        self.t = t
        self.shape = shape
    }

    func computeRefractiveIndices(_ allIntersections: [Intersection]) -> (Double, Double) {
        var n1 = 1.0
        var n2 = 1.0
        var containers: [Shape] = []
        for intersection in allIntersections {
            if intersection.t == self.t {
                if let lastContainer = containers.last {
                    n1 = lastContainer.material.refractive
                } else {
                    n1 = 1.0
                }
            }

            if let index = containers.firstIndex(where: { shape in
                shape.id == intersection.shape.id
            }) {
                containers.remove(at: index)
            } else {
                containers.append(intersection.shape)
            }

            if intersection.t == self.t {
                if let lastContainer = containers.last {
                    n2 = lastContainer.material.refractive
                } else {
                    n2 = 1.0
                }
            }
        }

        return (n1, n2)
    }

    func prepareComputations(_ ray: Ray, _ allIntersections: [Intersection]) -> Computations {
        let point = ray.position(self.t)
        let eye = ray.direction.negate()
        var normal = self.shape.normal(point)
        let isInside: Bool
        if normal.dot(eye) < 0 {
            isInside = true
            normal = normal.negate()
        } else {
            isInside = false
        }
        let overPoint = point.add(normal.multiplyScalar(EPSILON))
        let underPoint = point.subtract(normal.multiplyScalar(EPSILON))
        let reflected = ray.direction.reflect(normal)
        let (n1, n2) = self.computeRefractiveIndices(allIntersections)

        return Computations(
            t: self.t,
            object: self.shape,
            point: point,
            overPoint: overPoint,
            underPoint: underPoint,
            eye: eye,
            normal: normal,
            reflected: reflected,
            isInside: isInside,
            n1: n1,
            n2: n2
        )
    }
}

func hit(_ intersections: inout [Intersection]) -> Optional<Intersection> {
    intersections
        .sort(by: { i1, i2 in
            i1.t < i2.t
        })
    return intersections
        .filter({intersection in intersection.t > 0})
        .first
}

func shadowHit(_ intersections: inout [Intersection]) -> Optional<Intersection> {
    intersections
        .sort(by: { i1, i2 in
            i1.t < i2.t
        })
    return intersections
        .filter({intersection in intersection.t > 0 && intersection.shape.castsShadow})
        .first
}
