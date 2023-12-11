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
        self.children = builder()
    }

    public func populateParentCache(_ cache: inout [UUID : Shape], parent: Shape?) {
        if let parent {
            cache[self.id] = parent
        }

        for child in children {
            child.populateParentCache(&cache, parent: self)
        }
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

    public func includes(_ otherID: UUID) -> Bool {
        return id == otherID || children.contains(where: { shape in shape.includes(otherID) })
    }

    // The concept of a normal vector to a Group is meaningless and should never be called
    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        fatalError("Whoops... this should never be called for a Group shape")
    }
}
