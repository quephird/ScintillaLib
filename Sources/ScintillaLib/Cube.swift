//
//  Cube.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/27/21.
//

import Foundation

public class Cube: Shape {
    func checkAxis(_ originComponent: Double, _ directionComponent: Double) -> (Double, Double) {
        let tMinNumerator = (-1 - originComponent)
        let tMaxNumerator = (1 - originComponent)

        var tMin: Double
        var tMax: Double
        if abs(directionComponent) >= EPSILON {
            tMin = tMinNumerator / directionComponent
            tMax = tMaxNumerator / directionComponent
        } else {
            tMin = tMinNumerator * .infinity
            tMax = tMaxNumerator * .infinity
        }

        if tMin > tMax {
            return (tMax, tMin)
        } else {
            return (tMin, tMax)
        }
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        let (xTMin, xTMax) = self.checkAxis(localRay.origin[0], localRay.direction[0])
        let (yTMin, yTMax) = self.checkAxis(localRay.origin[1], localRay.direction[1])
        let (zTMin, zTMax) = self.checkAxis(localRay.origin[2], localRay.direction[2])

        let tMin = max(xTMin, yTMin, zTMin)
        let tMax = min(xTMax, yTMax, zTMax)

        if tMin > tMax {
            return []
        } else {
            return [
                Intersection(tMin, self),
                Intersection(tMax, self),
            ]
        }
    }

    override func localNormal(_ localPoint: Point, _ uv: UV) -> Vector {
        let maxComponent = max(abs(localPoint[0]), abs(localPoint[1]), abs(localPoint[2]))

        if maxComponent == abs(localPoint[0]) {
            return Vector(localPoint[0], 0, 0)
        } else if maxComponent == abs(localPoint[1]) {
            return Vector(0, localPoint[1], 0)
        } else {
            return Vector(0, 0, localPoint[2])
        }
    }
}
