//
//  ImplicitSurface.swift
//  
//
//  Created by Danielle Kefford on 10/1/22.
//

public typealias SurfaceFunction = (Double, Double, Double) -> Double
public typealias BoundingBox = ((Double, Double, Double), (Double, Double, Double))

let DELTA = 0.0000000001
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
        // First we check to see if the ray intersects the bounding box
        guard let boundingBoxIntersection = self.boundingBox.intersect(localRay)
            .first(where: { intersection in
                intersection.t > 0
            }) else {
            return []
        }

        // Next we substitute in the components of the inbound ray
        // to convert f(x, y, z) into F(t), a function solely dependent on t...
        func ft(_ t: Double) -> Double {
            self.f(
                localRay.origin.x + t*localRay.direction.x,
                localRay.origin.y + t*localRay.direction.y,
                localRay.origin.z + t*localRay.direction.z
            )
        }

        var t = boundingBoxIntersection.t
        var tPrev = 0.0
        var iterations = 0
        // TODO: iterate through the bounds
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
                    if abs(f) < DELTA {
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
