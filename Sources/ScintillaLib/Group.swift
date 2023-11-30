//
//  Group.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/30/21.
//

import Foundation

public struct Group: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()
    var children: [Shape] = []

    public init(@ShapeBuilder builder: () -> [Shape]) {
        let children = builder()
        for var child in children {
            child.parentBox = ParentBox(.group(self))
        }
        self.children = children
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

    // The concept of a normal vector to a Group is somewhat meaningless
    // but we have to fulfill the contract of Shape here
    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        return Vector(0, 0, 1)
    }

    mutating func addChild(_ childObject: Shape) {
        var copy = childObject
        copy.parentBox = ParentBox(Container.group(self))
        children.append(childObject)
    }
}
