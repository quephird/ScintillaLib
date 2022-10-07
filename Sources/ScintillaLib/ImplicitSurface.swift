//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

public typealias SurfaceFunction = (Double, Double, Double) -> Double

let DELTA = 0.0000000001
let MAX_ITERATIONS_NEWTON = 100
let MAX_ITERATIONS_BISECTION = 100

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

        var t = 0.0
        var tPrev = t
        var iterations = 0
        while iterations <= MAX_ITERATIONS_BISECTION {
            if ft(t) > 0 {
                tPrev = t
                t += 0.1
                iterations += 1
            } else {
                var a = tPrev
                var b = t
                while true {
                    t = (a+b)/2
                    let f = ft(t)
                    if abs(f) < EPSILON {
                        return [Intersection(t, self)]
                    } else if f > 0 {
                        a = t
                    } else {
                        b = t
                    }
                }

                break
            }
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
