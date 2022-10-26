//
//  Group.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/30/21.
//

import Foundation

public class Group: Shape {
    var children: [Shape] = []

    public init(@ShapeBuilder builder: () -> [Shape]) {
        self.children = builder()
        super.init()
        for child in children {
            child.parent = .group(self)
        }
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
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

    override func localNormal(_ localPoint: Point) -> Vector {
        return Vector(0, 0, 1)
    }

    func addChild(_ childObject: Shape) {
        self.children.append(childObject)
        childObject.parent = .group(self)
    }
}
