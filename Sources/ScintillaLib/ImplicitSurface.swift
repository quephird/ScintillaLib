//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

public typealias SurfaceFunction = (Double, Double, Double) -> Double
public typealias BoundingBox = ((Double, Double, Double), (Double, Double, Double))

let DELTA = 0.0000000001
let NUM_BOUNDING_BOX_SUBDIVSIONS = 100
let MAX_ITERATIONS_BISECTION = 100

public class ImplicitSurface: Shape {
    var f: SurfaceFunction
    var boundingBox: Cube = Cube(.basicMaterial())

    public init(_ material: Material, _ f: @escaping SurfaceFunction) {
        self.f = f
        super.init(material)
    }

    public init(_ material: Material, _ boundingBox: BoundingBox, _ f: @escaping SurfaceFunction) {
        let ((xMin, yMin, zMin), (xMax, yMax, zMax)) = boundingBox
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yMax-yMin)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yMax+yMin)/2, (zMax+zMin)/2)
        self.boundingBox = Cube(.basicMaterial())
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        self.f = f
        super.init(material)
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
        // and only continue through to the further one, computing a hit
        // using the bisection method.
        var t = tNearer
        let deltaT = (tFurther - tNearer)/Double(NUM_BOUNDING_BOX_SUBDIVSIONS)
        var tPrev = 0.0
        while t <= tFurther {
            if ft(t) > 0 {
                // If we're here, then we're outside the object and we should continue...
                tPrev = t
                t += deltaT
            } else {
                // ... but if we're here, then we're somewhere _inside_ the object,
                // and we need to refine t.
                var a = tPrev
                var b = t
                var iterations = 0
                while iterations <= MAX_ITERATIONS_BISECTION {
                    t = (a+b)/2
                    let f = ft(t)
                    if abs(f) < DELTA {
                        return [Intersection(t, self)]
                    } else if f > 0 {
                        a = t
                    } else {
                        b = t
                    }
                    iterations += 1
                }
                // If we got here, then we failed to converge on a value for t,
                // so for now assume that we have a miss
                break
            }
        }

        return []
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        // We take an approach below in approximating ∂F/∂x, ∂F/∂y, and ∂F/∂z
        // by computing the simple derivative using a very small value for Δx,
        // Δy, and Δz, respectively.
        let gradFx = (f(localPoint.x + DELTA, localPoint.y, localPoint.z) - f(localPoint.x - DELTA, localPoint.y, localPoint.z))
        let gradFy = (f(localPoint.x, localPoint.y + DELTA, localPoint.z) - f(localPoint.x, localPoint.y - DELTA, localPoint.z))
        let gradFz = (f(localPoint.x, localPoint.y, localPoint.z + DELTA) - f(localPoint.x, localPoint.y, localPoint.z - DELTA))

        return vector(gradFx, gradFy, gradFz).normalize()
    }
}
