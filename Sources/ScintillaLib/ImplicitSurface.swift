//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

import Foundation

public typealias SurfaceFunction = (Double, Double, Double) -> Double
public typealias Point3D = (Double, Double, Double)

let DELTA = 0.0000000001
let NUM_BOUNDING_BOX_SUBDIVSIONS = 100
let MAX_ITERATIONS_BISECTION = 100

public class ImplicitSurface: Shape {
    var f: SurfaceFunction
    var boundingShape: Shape

    public convenience init(_ center: Point3D, _ radius: Double, _ f: @escaping SurfaceFunction) {
        let (translateX, translateY, translateZ) = center
        let boundingShape = Sphere()
            .scale(radius, radius, radius)
            .translate(translateX, translateY, translateZ)
        self.init(boundingShape, f)
    }

    public convenience init(_ bottomFrontLeft: Point3D, _ topBackRight: Point3D, _ f: @escaping SurfaceFunction) {
        let (xMin, yMin, zMin) = bottomFrontLeft
        let (xMax, yMax, zMax) = topBackRight
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yMax-yMin)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yMax+yMin)/2, (zMax+zMin)/2)
        let boundingShape = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        self.init(boundingShape, f)
    }

    public init(_ boundingShape: Shape, _ f: @escaping SurfaceFunction) {
        self.boundingShape = boundingShape
        self.f = f
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // First we check to see if the ray intersects the bounding box;
        // note that we need a pair of hits in order to construct a range
        // of values for t below...
        let boundingBoxIntersections = self.boundingShape.intersect(localRay)
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
        var intersections: [Intersection] = []

        // Since we want to compute multiple intersections, we need to
        // track when we cross the surface, not just when we're inside it.
        // That is, if we begin outside the surface (f(t) > 0) and we
        // encounter a hit, then we're now inside the surface (f(t) < 0),
        // and the next hit will be when we go back _outside_ the surface.
        // Conversely, if we begin _inside_ the surface and we encounter a hit,
        // then we're now _outside_ the surface, and the next hit will be when
        // we go back _inside_ the surface. And so we need to keep flipping
        // `wasOutsideShape` accordingly, and our tests below need to consider
        // both it _and_ the value of f(t).
        var wasOutsideShape = ft(tPrev) > 0 ? true : false

        // Note that we add `deltaT` below just to make sure that we don't exit
        // the loop prematurely without getting that last hit if it's really close
        // to the bounding box
    outerWhile: while t <= tFurther + deltaT {
            if (ft(t) > 0 && wasOutsideShape) || (ft(t) < 0 && !wasOutsideShape) {
                // If we're here, then we haven't crossed the surface from outside to inside,
                // or vice versa, so we should continue searching...
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

                    if abs(f) < DELTA {
                        intersections.append(Intersection(t, self))
                        // Flip this variable since we now crossed a surface
                        wasOutsideShape = !wasOutsideShape
                        t += deltaT
                        continue outerWhile
                    } else if (f > 0 && wasOutsideShape) || (f < 0 && !wasOutsideShape) {
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
