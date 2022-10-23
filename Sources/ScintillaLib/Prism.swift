//
//  File.swift
//  
//
//  Created by Danielle Kefford on 10/21/22.
//

import Darwin

public class Prism: Shape {
    var xzPoints: [(Double, Double)]
    var yStart: Double
    var yEnd: Double
    var boundingBox: Cube

    public init(_ yStart: Double, _ yEnd: Double, _ xzPoints: [(Double, Double)]) {
        self.yStart = yStart
        self.yEnd = yEnd
        self.xzPoints = xzPoints
        let xMin = xzPoints.map { $0.0 }.min()!
        let xMax = xzPoints.map { $0.0 }.max()!
        let zMin = xzPoints.map { $0.1 }.min()!
        let zMax = xzPoints.map { $0.1 }.max()!
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yEnd-yStart)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yEnd+yStart)/2, (zMax+zMin)/2)
        self.boundingBox = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        super.init()
    }

    func neighboringPairs(_ points: [(Double, Double)]) -> [((Double, Double), (Double, Double))] {
        let rotatedPoints = Array(points[1...]) + [points[0]]
        return Array(zip(points, rotatedPoints))
    }

    func checkRectangle(_ ray: Ray, _ corner: Tuple4, _ side1: Tuple4, _ side2: Tuple4) -> Intersection? {
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
        if projectionToSide1.magnitude() <= side1.magnitude() &&
            projectionToSide2.magnitude() <= side2.magnitude() {
            return Intersection(t, self)
        }

        // Point falls outside the rectangle
        return nil
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // Check bounding box
        let boundingBoxIntersections = self.boundingBox.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        // Check sides of prism
        var intersections: [Intersection] = []
        // For each pair of neighboring points...
        for (point1, point2) in neighboringPairs(self.xzPoints) {
            let corner = point(point1.0, yStart, point1.1)
            let bottomSide = vector(point2.0-point1.0, 0, point2.1-point1.1)
            let leftSide = vector(0, yEnd-yStart, 0)
            if let intersection = self.checkRectangle(localRay, corner, bottomSide, leftSide) {
                intersections.append(intersection)
            }
        }

        // TODO: Check both caps

        return intersections
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        return vector(0, 0, 1)
    }
}
