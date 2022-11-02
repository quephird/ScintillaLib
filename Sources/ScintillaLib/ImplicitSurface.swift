//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

import Foundation

public typealias SurfaceFunction = (Double, Double, Double) -> Double
public typealias BoundingBox = ((Double, Double, Double), (Double, Double, Double))

let DELTA = 0.0000000001
let NUM_BOUNDING_BOX_SUBDIVSIONS = 100
let MAX_ITERATIONS_BISECTION = 100

public class ImplicitSurface: Shape {
    var f: SurfaceFunction
    var boundingBox: Cube = Cube()

    public init(_ f: @escaping SurfaceFunction) {
        self.f = f
    }

    public init(_ boundingBox: BoundingBox, _ f: @escaping SurfaceFunction) {
        let ((xMin, yMin, zMin), (xMax, yMax, zMax)) = boundingBox
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yMax-yMin)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yMax+yMin)/2, (zMax+zMin)/2)
        self.boundingBox = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        self.f = f
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // First we check to see if the ray intersects the bounding box;
        // note that we need a pair of hits in order to construct a range
        // of values for t below...
        let boundingBoxIntersections = self.boundingBox.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }
        let tNearer = boundingBoxIntersections[0].t
        let tFurther = boundingBoxIntersections[1].t

        // ... then we substitute in the components of the inbound ray
        // to convert f(x, y, z) into F(t), a function solely dependent on t...
        func ft(_ t: Double) -> Double {
            self.f(
                localRay.origin.x + t*localRay.direction.x,
                localRay.origin.y + t*localRay.direction.y,
                localRay.origin.z + t*localRay.direction.z
            )
        }

        // ... next we begin advancing from the nearer point of intersection
        // and continue through to the further one, computing a hit
        // using the bisection method.
        var t = tNearer
        let deltaT = (tFurther - tNearer)/Double(NUM_BOUNDING_BOX_SUBDIVSIONS)
        var tPrev = 0.0

//        if (tNearer < 0.0) {
//            print(tNearer)
//            print(tFurther)
//        }
        var intersections: [Intersection] = []
        var wasOutsideShape = ft(tPrev) > 0 ? true : false
        while t <= tFurther {
            if (ft(t) > 0 && wasOutsideShape) || (ft(t) < 0 && !wasOutsideShape) {
                // If we're here, then we haven't crossed a boundary, so we should continue...
                tPrev = t
                t += deltaT
            } else {
                // ... but if we're here, then we've either suddenly moved inside
                // the object, or suddenly moved outside it, and we need to refine t.
                var a = tPrev
                var b = t
                var iterations = 0
                while iterations <= MAX_ITERATIONS_BISECTION {
                    t = (a+b)/2
                    let f = ft(t)
//                    print("\(a), \(b), \(iterations)")
                    if abs(f) < DELTA {
                        intersections.append(Intersection(t, self))
                        wasOutsideShape = !wasOutsideShape
                        break
//                    } else if abs(a-b) < DELTA {
////                        print("BOOM!")
//                        t += deltaT
//                        break
                    } else if f > 0 {
                        a = t
                    } else {
                        b = t
                    }
                    iterations += 1
                }

                // If we got here, then we failed to converge on a value for t,
                // so for now assume that we have a miss
                t += deltaT
                break
            }
            t += deltaT
        }

        if intersections.count > 1 {
            print("I got here")
        }
        return intersections
    }

    override func localNormal(_ localPoint: Point) -> Vector {
        // We take an approach below in approximating ∂F/∂x, ∂F/∂y, and ∂F/∂z
        // by computing the simple derivative using a very small value for Δx,
        // Δy, and Δz, respectively.
        let gradFx = (f(localPoint.x + DELTA, localPoint.y, localPoint.z) - f(localPoint.x - DELTA, localPoint.y, localPoint.z))
        let gradFy = (f(localPoint.x, localPoint.y + DELTA, localPoint.z) - f(localPoint.x, localPoint.y - DELTA, localPoint.z))
        let gradFz = (f(localPoint.x, localPoint.y, localPoint.z + DELTA) - f(localPoint.x, localPoint.y, localPoint.z - DELTA))

        return Vector(gradFx, gradFy, gradFz).normalize()
    }
}
