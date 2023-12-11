//
//  CSG.swift
//  Scintilla
//
//  Created by Danielle Kefford on 12/2/21.
//

import Foundation

public struct CSG: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()

    var operation: Operation
    var left: Shape
    var right: Shape

    public init(_ operation: Operation, _ left: Shape, _ right: Shape) {
        self.operation = operation
        self.left = left
        self.right = right
    }

    public func populateParentCache(_ cache: inout [UUID : Shape], parent: Shape?) {
        if let parent {
            cache[self.id] = parent
        }

        left.populateParentCache(&cache, parent: self)
        right.populateParentCache(&cache, parent: self)
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
        var insideLeft = false
        var insideRight = false

        // Prepare a list to receive the filtered intersections
        var filteredIntersections: [Intersection] = []

        for intersection in allIntersections {
            // If the intersection's object is part of the "left" child,
            // then leftHit is true
            let leftHit = self.left.includes(intersection.shape)

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

    @_spi(Testing) public func localIntersect(_ localRay: Ray) -> [Intersection] {
        let leftIntersections = self.left.intersect(localRay)
        let rightIntersections = self.right.intersect(localRay)

        var allIntersections = leftIntersections
        allIntersections.append(contentsOf: rightIntersections)
        allIntersections.sort(by: { i1, i2 in
            i1.t < i2.t
        })

        return self.filterIntersections(allIntersections)
    }

    public func includes(_ otherID: UUID) -> Bool {
        return id == otherID || left.includes(otherID) || right.includes(otherID)
    }

    // The concept of a normal vector to a CSG object is meaningless and should never be called
    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        fatalError("Whoops... this should never be called for a Group shape")
    }
}
