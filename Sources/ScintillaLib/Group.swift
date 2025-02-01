//
//  Group.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/30/21.
//

import Foundation

public struct Group: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()
    public var children: [any Shape] = []

    public init(@ShapeBuilder builder: () -> [any Shape]) {
        let children = builder()
        for var child in children {
            child.parentId = self.id
            self.children.append(child)
        }
    }

    public func findShape(_ shapeId: UUID) -> (any Shape)? {
        for shape in self.children {
            if shape.id == shapeId {
                return shape
            }

            switch shape {
            case let csg as CSG:
                if let shape = csg.findShape(shapeId) {
                    return shape
                }
            case let group as Group:
                if let shape = group.findShape(shapeId) {
                    return shape
                }
            default:
                continue
            }
        }

        return nil
    }

    @_spi(Testing) public func localIntersect(_ localRay: Ray) -> [Intersection] {
        var allIntersections: [Intersection] = []

        for child in children {
            let intersections = child.intersect(localRay)
            allIntersections.append(contentsOf: intersections)
        }

        allIntersections.sort(by: { i1, i2 in
            i1.t < i2.t
        })
        return allIntersections
    }

    // The concept of a normal vector to a Group is meaningless and should never be called
    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        fatalError("Whoops... this should never be called for a Group shape")
    }
}
