//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

public typealias SurfaceFunction = (Double, Double, Double) -> Double

let DELTA = 0.0000000001
let MAX_ITERATIONS_NEWTON = 100

public class ImplicitSurface: Shape {
    var f: SurfaceFunction

    public init(_ material: Material, _ f: @escaping SurfaceFunction) {
        self.f = f
        super.init(material)
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // This is an alternative implementation of Newton's method
        // for finding a root of the equation F(t) = 0.
        //
        // First we substitute in the components of the inbound ray
        // to convert f(x, y, z) into F(t)...
        func ft(_ t: Double) -> Double {
            self.f(
                localRay.origin.x + t*localRay.direction.x,
                localRay.origin.y + t*localRay.direction.y,
                localRay.origin.z + t*localRay.direction.z
            )
        }

        // ... then we approximate the derivative of F(t) by using a
        // small value for Δt...
        func fPrimeT(_ t: Double) -> Double {
            (ft(t + DELTA) - ft(t - DELTA))/2/DELTA
        }

        // ... then we proceed to Newton's method, starting at t=0,
        // which is where the camera is. Note that there is no guarantee
        // that this yields the root with the smallest positive value of t.
        // There is a chance that we either find another root or miss
        // finding one entirely, which can result in certain shapes being
        // rendered with acne or not rendering at all.
        var tPrev: Double = 0.0
        var t: Double
        var iterations = 0
        while iterations <= MAX_ITERATIONS_NEWTON {
            t = tPrev - ft(tPrev)/fPrimeT(tPrev)
            if abs(tPrev - t) < DELTA {
                return [Intersection(t, self)]
            }

            tPrev = t
            iterations += 1
        }

        return []
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        // We take an approach below in approximating ∂F/∂x, ∂F/∂y, and ∂F/∂z
        // that is similar to the one above for finding the simple derivative
        let gradFx = (f(localPoint.x + DELTA, localPoint.y, localPoint.z) - f(localPoint.x - DELTA, localPoint.y, localPoint.z))
        let gradFy = (f(localPoint.x, localPoint.y + DELTA, localPoint.z) - f(localPoint.x, localPoint.y - DELTA, localPoint.z))
        let gradFz = (f(localPoint.x, localPoint.y, localPoint.z + DELTA) - f(localPoint.x, localPoint.y, localPoint.z - DELTA))

        return vector(gradFx, gradFy, gradFz).normalize()
    }
}
