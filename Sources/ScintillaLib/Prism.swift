//
//  File.swift
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

    // TODO: Get rid of this, use indexing strategy instead
    func neighboringPairs(_ points: [(Double, Double)]) -> [((Double, Double), (Double, Double))] {
        let rotatedPoints = Array(points[1...]) + [points[0]]
        return Array(zip(points, rotatedPoints))
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // Check bounding box
        let boundingBoxIntersections = self.boundingBox.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        var intersections: [Intersection] = []

        // Check sides of prism
        // For each pair of neighboring points...
//        for (i, (x1, z1)) in self.xzPoints.enumerated() {
//            let cornerVertex = point(x1, yBase, z1)
//            let (x2, z2) = self.xzPoints[(i+1)%self.xzPoints.count]
//            let bottomSide = vector(x2-x1, 0, z2-z1)
//            let leftSide = vector(0, yTop-yBase, 0)
//            if let t = checkRectangle(localRay, cornerVertex, bottomSide, leftSide) {
//                intersections.append(Intersection(t, self))
//            }
//        }

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

    // Only points that actually exist on the shape should ever be
    // passed in, so all we should have to do is figure out which side
    // or cap it exists on
    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        // Check if point is on the base
        if isInsidePolygon(localPoint, self.xzPoints, self.yBase) {
            return vector(0, -1, 0)
        }

        // Check if point is on the top
        if isInsidePolygon(localPoint, self.xzPoints, self.yTop) {
            return vector(0, 1, 0)
        }

        // Check if the point resides on one of the sides
        for (point1, point2) in neighboringPairs(self.xzPoints) {
            let corner = point(point1.0, yBase, point1.1)
            let bottomSide = vector(point2.0-point1.0, 0, point2.1-point1.1)
            let leftSide = vector(0, yTop-yBase, 0)
            let pointToCorner = localPoint.subtract(corner)
            let normal = bottomSide.cross(leftSide)
            if pointToCorner.dot(normal) < EPSILON {
                return normal
            }
        }

        // We shouldn't get here
        return vector(0, 0, 0)
    }
}

func checkRectangle(_ ray: Ray, _ corner: Tuple4, _ side1: Tuple4, _ side2: Tuple4) -> Double? {
    // Compute the normal to the rectangle by taking the cross product of the two sides
    let normal = side1.cross(side2).normalize()

    // Effectively compute the angle between the ray and the normal vector
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
        projectionToSide2.normalize().isAlmostEqual(side2.normalize()) {
        return t
    }

    // Point falls outside the rectangle
    return nil
}

// This checks to see if the local point passed in is inside the
// polygon formed by points made from the (x, y, z) tuples themselves
// made with the xz-tuples passed in and the inbound y-coordinate fixed.
// Method taken from https://stackoverflow.com/a/43813314
func isInsidePolygon(_ localPoint: Tuple4, _ xzTuples: [(Double, Double)], _ y: Double) -> Bool {
    var totalAngle = 0.0
    let pointCount = xzTuples.count
    for (i, (x1, z1)) in xzTuples.enumerated() {
        let (x2, z2) = xzTuples[(i+1)%pointCount]

        let vertex1 = point(x1, y, z1)
        let vertex2 = point(x2, y, z2)

        let vector1 = vertex1.subtract(localPoint)
        let vector2 = vertex2.subtract(localPoint)

        let angle = vector1.angle(vector2)
        if vector2.cross(vector1).dot(vector(0, 1, 0)) > 0.0 {
            totalAngle += angle
        } else {
            totalAngle -= angle
        }
    }

    if totalAngle.isAlmostEqual(2*PI) {
        return true
    }

    return false
}
