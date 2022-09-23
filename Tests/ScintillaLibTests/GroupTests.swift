//
//  GroupTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/30/21.
//

import XCTest

class GroupTests: XCTestCase {
    func testLocalIntersectWithEmptyGroup() throws {
        let group = Group { }
        let ray = Ray(point(0, 0, 0), vector(0, 0, 1))
        let allIntersections = group.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 0)
    }

    func testLocalIntersectWithNonEmptyGroup() throws {
        let s1 = Sphere(.basicMaterial())
        let s2 = Sphere(.basicMaterial())
            .translate(0, 0, -3)
        let s3 = Sphere(.basicMaterial())
            .translate(5, 0, 0)
        let group = Group {
            s1
            s2
            s3
        }

        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let allIntersections = group.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 4)
        XCTAssertEqual(allIntersections[0].shape.id, s2.id)
        XCTAssertEqual(allIntersections[1].shape.id, s2.id)
        XCTAssertEqual(allIntersections[2].shape.id, s1.id)
        XCTAssertEqual(allIntersections[3].shape.id, s1.id)
    }

    func testLocalIntersectWithTransformedGroup() throws {
        let group = Group {
            Sphere(.basicMaterial())
                .translate(5, 0, 0)
        }
            .scale(2, 2, 2)

        let ray = Ray(point(10, 0, -10), vector(0, 0, 1))
        let allIntersections = group.intersect(ray)
        XCTAssertEqual(allIntersections.count, 2)
    }
}
