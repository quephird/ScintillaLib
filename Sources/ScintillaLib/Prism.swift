//
//  Prism.swift
//  
//
//  Created by Danielle Kefford on 10/21/22.
//

import Darwin

public class Prism: Shape {
    var xzPoints: [(Double, Double)]
    var yBase: Double
    var yTop: Double
    var boundingBox: Cube

    public init(_ yBase: Double, _ yTop: Double, _ xzPoints: [(Double, Double)]) {
        self.yBase = yBase
        self.yTop = yTop
        self.xzPoints = xzPoints
        let xMin = xzPoints.map { $0.0 }.min()!
        let xMax = xzPoints.map { $0.0 }.max()!
        let zMin = xzPoints.map { $0.1 }.min()!
        let zMax = xzPoints.map { $0.1 }.max()!
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yTop-yBase)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yTop+yBase)/2, (zMax+zMin)/2)
        self.boundingBox = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        super.init()
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // Check bounding box and bail if the ray misses
        let boundingBoxIntersections = self.boundingBox.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        var intersections: [Intersection] = []

        // Check sides of prism
        for (i, (x1, z1)) in self.xzPoints.enumerated() {
            let cornerVertex = Point(x1, yBase, z1)
            let (x2, z2) = self.xzPoints[(i+1)%self.xzPoints.count]
            let bottomSide = Vector(x2-x1, 0, z2-z1)
            let leftSide = Vector(0, yTop-yBase, 0)
            if let t = checkRectangle(localRay, cornerVertex, bottomSide, leftSide) {
                intersections.append(Intersection(t, self))
            }
        }

        // Check if ray hits base of prism
        let basePlane = Plane().translate(0, yBase, 0)
        if let planeIntersection = basePlane.intersect(localRay).first {
            let maybeHitPoint = localRay.position(planeIntersection.t)
            if isInsidePolygon(maybeHitPoint, self.xzPoints, yBase) {
                intersections.append(Intersection(planeIntersection.t, self))
            }
        }

        // Check if ray hits top of prism
        let topPlane = Plane().translate(0, yTop, 0)
        if let planeIntersection = topPlane.intersect(localRay).first {
            let maybeHitPoint = localRay.position(planeIntersection.t)
            if isInsidePolygon(maybeHitPoint, self.xzPoints, yTop) {
                intersections.append(Intersection(planeIntersection.t, self))
            }
        }

        return intersections
    }

    // Only points that actually exist somewhere on the shape should ever be
    // passed in, so all we should have to do is figure out which side
    // or cap it exists on.
    override func localNormal(_ localPoint: Point) -> Vector {
        // Check if the point resides on one of the sides
        for (i, (x1, z1)) in self.xzPoints.enumerated() {
            let (x2, z2) = self.xzPoints[(i+1)%self.xzPoints.count]
            let corner = Point(x1, yBase, z1)
            let bottomSide = Vector(x2-x1, 0, z2-z1)
            let leftSide = Vector(0, yTop-yBase, 0)
            let pointToCorner = localPoint.subtract(corner)
            let normal = leftSide.cross(bottomSide).normalize()
            if abs(pointToCorner.dot(normal)) < EPSILON {
                return normal
            }
        }

        // Check if point is on the base
        if isInsidePolygon(localPoint, self.xzPoints, self.yBase) {
            return Vector(0, -1, 0)
        }

        // Check if point is on the top
        if isInsidePolygon(localPoint, self.xzPoints, self.yTop) {
            return Vector(0, 1, 0)
        }

        // We shouldn't ever get here
        return Vector(0, 0, 0)
    }
}

// Returns the t value for where the ray hits the rectangle
// formed by the two sides and positioned at the corner passed in.
// Method taken from https://stackoverflow.com/a/8862483
func checkRectangle(_ ray: Ray, _ corner: Point, _ side1: Vector, _ side2: Vector) -> Double? {
    // Compute the normal to the rectangle by taking the cross product of the two sides
    let normal = side2.cross(side1).normalize()

    // Compute the angle between the ray and the normal vector
    let dDotN = ray.direction.dot(normal)
    if abs(dDotN) < EPSILON {
        // Ray is effectively parallel to side and thus cannot possibly intersect it
        return nil
    }

    // Calculate the value of t where the ray intersects the plane formed by the two sides
    let t = (corner.subtract(ray.origin).dot(normal))/dDotN
    let point = ray.position(t)

    // Project the vector from the corner to the point of intersection onto the two sides
    let cornerToPoint = point.subtract(corner)
    let projectionToSide1 = cornerToPoint.project(side1)
    let projectionToSide2 = cornerToPoint.project(side2)

    // ... and then check that it's within the bounds of the rectangle
    if projectionToSide1.normalize().isAlmostEqual(side1.normalize()) &&
        projectionToSide1.magnitude() <= side1.magnitude() &&
        projectionToSide2.normalize().isAlmostEqual(side2.normalize()) &&
        projectionToSide2.magnitude() <= side2.magnitude() {
        // ... and here we have a valid hit.
        return t
    }

    // If we got here, then the point falls outside the rectangle.
    return nil
}

// This checks to see if the local point passed in is inside the
// polygon formed by points made from the (x, y, z) tuples themselves
// made with the xz-tuples passed in and the inbound y-coordinate fixed.
// Method taken from https://stackoverflow.com/a/43813314
func isInsidePolygon(_ localPoint: Point, _ xzTuples: [(Double, Double)], _ y: Double) -> Bool {
    var totalAngle = 0.0
    let pointCount = xzTuples.count
    for (i, (x1, z1)) in xzTuples.enumerated() {
        let (x2, z2) = xzTuples[(i+1)%pointCount]

        // Compute the two vertices in focus for this iteration...
        let vertex1 = Point(x1, y, z1)
        let vertex2 = Point(x2, y, z2)

        // ... then form the two vectors from the local point to each vertex...
        let vector1 = vertex1.subtract(localPoint)
        let vector2 = vertex2.subtract(localPoint)

        // ... next compute the raw angle between those two vectors...
        let angle = vector1.angle(vector2)

        // ... finally, we assign a direction of sorts to the angle
        // by checking to see if the cross product of the two vectors
        // points upward or downward.
        if vector2.cross(vector1).dot(Vector(0, 1, 0)) > 0.0 {
            totalAngle += angle
        } else {
            totalAngle -= angle
        }
    }

    // If the sum of the all the angles is 2π, then we are inside the polygon...
    if totalAngle.isAlmostEqual(2*PI) {
        return true
    }

    // ... otherwise, we are outside.
    return false
}
