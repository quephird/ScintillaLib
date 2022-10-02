//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

public typealias SurfaceFunction = (Double, Double, Double) -> Double

let MAX_ITERATIONS_NEWTON = 100

public class ImplicitSurface: Shape {
    var f: SurfaceFunction

    public init(_ material: Material, _ f: @escaping SurfaceFunction) {
        self.f = f
        super.init(material)
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        func ft(_ t: Double) -> Double {
            self.f(
                localRay.origin.x + t*localRay.direction.x,
                localRay.origin.y + t*localRay.direction.y,
                localRay.origin.z + t*localRay.direction.z
            )
        }
        func fPrimeT(_ t: Double) -> Double {
            (ft(t + EPSILON) - ft(t))/EPSILON
        }

        var tPrev: Double = 0.0
        var t: Double
        var iterations = 0
        while true {
            t = tPrev - ft(tPrev)/fPrimeT(tPrev)
            if abs(tPrev - t) < EPSILON {
                return [Intersection(t, self)]
            }

            if iterations == MAX_ITERATIONS_NEWTON {
                break
            }

            tPrev = t
            iterations += 1
        }

        return []
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        let gradFx = (f(localPoint.x + EPSILON, localPoint.y, localPoint.z) - f(localPoint.x, localPoint.y, localPoint.z))/EPSILON
        let gradFy = (f(localPoint.x, localPoint.y + EPSILON, localPoint.z) - f(localPoint.x, localPoint.y, localPoint.z))/EPSILON
        let gradFz = (f(localPoint.x, localPoint.y, localPoint.z + EPSILON) - f(localPoint.x, localPoint.y, localPoint.z))/EPSILON

        return vector(gradFx, gradFy, gradFz).normalize()
    }
}
