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
        let bottomFrontLeft = (-1.0 - EPSILON, -1.0 - EPSILON, -1.0 - EPSILON)
        let topBackRight = (1.0 + EPSILON, 1.0 + EPSILON, 1.0 + EPSILON)

        func f(_ x: Double, _ y: Double, _ z: Double) -> Double {
            pow(pow(abs(x), 2.0/e) + pow(abs(y), 2.0/e), e/n) + pow(abs(z), 2.0/n) - 1.0
        }

        let underlyingImplicitSurface = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight, f)
        self.underlyingImplicitSurface = underlyingImplicitSurface
    }

    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        return self.underlyingImplicitSurface
            .localIntersect(localRay)
            .map { intersection in
                return Intersection(intersection.t, self)
            }
    }

    @_spi(Testing) public override func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        return self.underlyingImplicitSurface.localNormal(localPoint)
    }
}
