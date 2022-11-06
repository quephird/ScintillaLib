//
//  SuperellipsoidTests.swift
//  
//
//  Created by Danielle Kefford on 11/4/22.
//

import XCTest
@testable import ScintillaLib

class SuperellipsoidTests: XCTestCase {
    func testLocalIntersectRoundedCubeHitsMiddle() throws {
        let shape = Superellipsoid(0.25, 0.25)
        let ray = Ray(Point(0.0, 0.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(3.0))
    }

    func testLocalIntersectRoundedCubeHitTopLeftCorner() throws {
        let shape = Superellipsoid(0.25, 0.25)
        let ray = Ray(Point(0.9, 0.9, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        // NOTA BENE: Note that the values of t are not -1 and 1,
        // respectively, like what would happen if this same ray
        // hit a pure cube shape, and is due to the curvature of the shape.
        XCTAssert(intersections[0].t.isAlmostEqual(1.21855))
        XCTAssert(intersections[1].t.isAlmostEqual(2.78145))
    }

    func testLocalIntersectRoundedCubeMissesCorner() throws {
        let shape = Superellipsoid(0.25, 0.25)
        let ray = Ray(Point(0.99, 0.99, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 0)
    }

    func testLocalIntersectRoundedCylinderHitsMiddle() throws {
        let shape = Superellipsoid(1.0, 0.25)
        let ray = Ray(Point(0.0, 0.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(3.0))
    }

    func testLocalIntersectRoundedCylinderHitsTopLeft() throws {
        let shape = Superellipsoid(1.0, 0.25)
        let ray = Ray(Point(0.7071, 0.7071, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(1.69408))
        XCTAssert(intersections[1].t.isAlmostEqual(2.30592))
    }

    func testLocalIntersectRoundedCylinderBarelyMissesTopLeft() throws {
        let shape = Superellipsoid(1.0, 0.25)
        let ray = Ray(Point(0.7072, 0.7072, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 0)
    }
}
