//
//  Superellipsoid.swift
//  
//
//  Created by Danielle Kefford on 11/4/22.
//

import Darwin

public class Superellipsoid: Shape {
    var underlyingImplicitSurface: ImplicitSurface

    public init(_ e: Double, _ n: Double) {
        let bottomLeftFront = (-1.0 - EPSILON, -1.0 - EPSILON, -1.0 - EPSILON)
        let topRightBack = (1.0 + EPSILON, 1.0 + EPSILON, 1.0 + EPSILON)

        func f(_ x: Double, _ y: Double, _ z: Double) -> Double {
            pow(pow(abs(x), 2.0/e) + pow(abs(y), 2.0/e), e/n) + pow(abs(z), 2.0/n) - 1.0
        }

        let underlyingImplicitSurface = ImplicitSurface(bottomLeftFront, topRightBack, f)
        self.underlyingImplicitSurface = underlyingImplicitSurface
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        return self.underlyingImplicitSurface
            .localIntersect(localRay)
            .map { intersection in
                return Intersection(intersection.t, self)
            }
    }

    override func localNormal(_ localPoint: Point) -> Vector {
        return self.underlyingImplicitSurface.localNormal(localPoint)
    }
}
