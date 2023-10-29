//
//  CSG.swift
//  Scintilla
//
//  Created by Danielle Kefford on 12/2/21.
//

import Foundation

public class CSG: Shape {
    var operation: Operation
    var left: Shape
    var right: Shape

    public init(_ operation: Operation, _ left: Shape, _ right: Shape) {
        self.operation = operation
        self.left = left
        self.right = right
        super.init()
        left.parent = .csg(self)
        right.parent = .csg(self)
    }

    static func makeCSG(_ operation: Operation, _ baseShape: Shape, @ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        let rightShapes = otherShapesBuilder()

        return rightShapes.reduce(baseShape) { partialResult, rightShape in
            CSG(operation, partialResult, rightShape)
        }
    }

    func isIntersectionAllowed(_ leftHit: Bool, _ insideLeft: Bool, _ insideRight: Bool) -> Bool {
        switch self.operation {
        case .union:
            return (leftHit && !insideRight) || (!leftHit && !insideLeft)
        case .intersection:
            return (leftHit && insideRight) || (!leftHit && insideLeft)
        case .difference:
            return (leftHit && !insideRight) || (!leftHit && insideLeft)
        }
    }

    @_spi(Testing) public func filterIntersections(_ allIntersections: [Intersection]) -> [Intersection] {
        // Begin outside of both children
        var leftHit = false
        var insideLeft = false
        var insideRight = false

        // Prepare a list to receive the filtered intersections
        var filteredIntersections: [Intersection] = []

        for intersection in allIntersections {
            // If the intersection's object is part of the "left" child,
            // then leftHit is true
            leftHit = self.left.includes(intersection.shape)

            if self.isIntersectionAllowed(leftHit, insideLeft, insideRight) {
                filteredIntersections.append(intersection)
            }

            // Depending on which object was hit, toggle either insideLeft or insideRight
            if leftHit {
                insideLeft = !insideLeft
            } else {
                insideRight = !insideRight
            }
        }

        return filteredIntersections
    }

    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        let leftIntersections = self.left.intersect(localRay)
        let rightIntersections = self.right.intersect(localRay)

        var allIntersections = leftIntersections
        allIntersections.append(contentsOf: rightIntersections)
        allIntersections.sort(by: { i1, i2 in
            i1.t < i2.t
        })

        return self.filterIntersections(allIntersections)
    }
}
