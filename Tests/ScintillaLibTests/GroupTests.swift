//
//  GroupTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/30/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class GroupTests: XCTestCase {
    func testLocalIntersectWithEmptyGroup() throws {
        let group = Group { }
        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let allIntersections = group.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 0)
    }

    func testLocalIntersectWithNonEmptyGroup() throws {
        let s1 = Sphere()
        let s2 = Sphere()
            .translate(0, 0, -3)
        let s3 = Sphere()
            .translate(5, 0, 0)
        let group = Group {
            s1
            s2
            s3
        }

        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let allIntersections = group.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 4)
        XCTAssertEqual(allIntersections[0].shape.id, s2.id)
        XCTAssertEqual(allIntersections[1].shape.id, s2.id)
        XCTAssertEqual(allIntersections[2].shape.id, s1.id)
        XCTAssertEqual(allIntersections[3].shape.id, s1.id)
    }

    func testLocalIntersectWithTransformedGroup() throws {
        let group = Group {
            Sphere()
                .translate(5, 0, 0)
        }
            .scale(2, 2, 2)

        let ray = Ray(Point(10, 0, -10), Vector(0, 0, 1))
        let allIntersections = group._intersect(ray)
        XCTAssertEqual(allIntersections.count, 2)
    }
}
