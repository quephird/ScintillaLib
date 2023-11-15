//
//  PlaneTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/24/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class PlaneTests: XCTestCase {
    func testLocalNormal() throws {
        let plane = Plane()
        let n1 = plane.localNormal(Point(0, 0, 0))
        let n2 = plane.localNormal(Point(10, 0, -10))
        let n3 = plane.localNormal(Point(-5, 0, 150))
        XCTAssertTrue(n1.isAlmostEqual(Vector(0, 1, 0)))
        XCTAssertTrue(n2.isAlmostEqual(Vector(0, 1, 0)))
        XCTAssertTrue(n3.isAlmostEqual(Vector(0, 1, 0)))
    }

    func testLocalIntersectWithParallelRay() throws {
        let plane = Plane()
        let ray = Ray(Point(0, 10, 0), Vector(0, 0, 1))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 0)
    }

    func testLocalIntersectWithCoplanarRay() throws {
        let plane = Plane()
        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 0)
    }

    func testLocalIntersectFromAbove() throws {
        let plane = Plane()
        let ray = Ray(Point(0, 1, 0), Vector(0, -1, 0))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 1)
        XCTAssertTrue(intersections[0].t == 1)
    }

    func testLocalIntersectFromBelow() throws {
        let plane = Plane()
        let ray = Ray(Point(0, -1, 0), Vector(0, 1, 0))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 1)
        XCTAssertTrue(intersections[0].t == 1)
    }
}
