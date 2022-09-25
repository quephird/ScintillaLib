//
//  PlaneTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/24/21.
//

import XCTest
@testable import ScintillaLib

class PlaneTests: XCTestCase {
    func testLocalNormal() throws {
        let plane = Plane(.basicMaterial())
        let n1 = plane.localNormal(point(0, 0, 0))
        let n2 = plane.localNormal(point(10, 0, -10))
        let n3 = plane.localNormal(point(-5, 0, 150))
        XCTAssertTrue(n1.isAlmostEqual(vector(0, 1, 0)))
        XCTAssertTrue(n2.isAlmostEqual(vector(0, 1, 0)))
        XCTAssertTrue(n3.isAlmostEqual(vector(0, 1, 0)))
    }

    func testLocalIntersectWithParallelRay() throws {
        let plane = Plane(.basicMaterial())
        let ray = Ray(point(0, 10, 0), vector(0, 0, 1))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 0)
    }

    func testLocalIntersectWithCoplanarRay() throws {
        let plane = Plane(.basicMaterial())
        let ray = Ray(point(0, 0, 0), vector(0, 0, 1))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 0)
    }

    func testLocalIntersectFromAbove() throws {
        let plane = Plane(.basicMaterial())
        let ray = Ray(point(0, 1, 0), vector(0, -1, 0))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 1)
        XCTAssertTrue(intersections[0].t == 1)
    }

    func testLocalIntersectFromBelow() throws {
        let plane = Plane(.basicMaterial())
        let ray = Ray(point(0, -1, 0), vector(0, 1, 0))
        let intersections = plane.localIntersect(ray)
        XCTAssertTrue(intersections.count == 1)
        XCTAssertTrue(intersections[0].t == 1)
    }
}
