//
//  Intersection.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

@available(macOS 10.15, *)
public struct Intersection {
    @_spi(Testing) public var t: Double
    @_spi(Testing) public var shape: Shape
    @_spi(Testing) public var uv: UV

    @_spi(Testing) public init(_ t: Double, _ shape: Shape) {
        self.init(t, .none, shape)
    }

    @_spi(Testing) public init(_ t: Double, _ uv: UV, _ shape: Shape) {
        self.t = t
        self.shape = shape
        self.uv = uv
    }

    func computeRefractiveIndices(_ allIntersections: [Intersection]) -> (Double, Double) {
        var n1 = 1.0
        var n2 = 1.0
        var containers: [Shape] = []
        for intersection in allIntersections {
            if intersection.t == self.t {
                if let lastContainer = containers.last {
                    n1 = lastContainer.material.properties.refractive
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
                    n2 = lastContainer.material.properties.refractive
                } else {
                    n2 = 1.0
                }
            }
        }

        return (n1, n2)
    }

    @_spi(Testing) public func prepareComputations(_ world: World, _ ray: Ray, _ allIntersections: [Intersection]) async -> Computations {
        let point = ray.position(self.t)
        let eye = ray.direction.negate()
        var normal = await self.shape.normal(world, point, self.uv)
        let isInside: Bool
        if normal.dot(eye) < 0 {
            isInside = true
            normal = normal.negate()
        } else {
            isInside = false
        }
        let overPoint = point.add(normal.multiply(EPSILON))
        let underPoint = point.subtract(normal.multiply(EPSILON))
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

@available(macOS 10.15, *)
@_spi(Testing) public func hit(_ intersections: [Intersection], includeOnlyShadowingObjects: Bool = false) -> Optional<Intersection> {
    return intersections
        .sorted(by: { i1, i2 in
            i1.t < i2.t
        })
        .filter { intersection in
            intersection.t > 0 && (includeOnlyShadowingObjects ? intersection.shape.castsShadow : true)
        }
        .first
}
