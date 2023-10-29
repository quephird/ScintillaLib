//
//  SphereTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class SphereTests: XCTestCase {
    func testIntersectTangent() throws {
        let r = Ray(Point(0, 1, -5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 1)
        XCTAssert(intersections[0].t.isAlmostEqual(5.0))
    }

    func testIntersectMiss() throws {
        let r = Ray(Point(0, 2, -5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 0)
    }

    func testIntersectInside() throws {
        let r = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(1.0))
    }

    func testIntersectSphereBehind() throws {
        let r = Ray(Point(0, 0, 5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-6.0))
        XCTAssert(intersections[1].t.isAlmostEqual(-4.0))
    }

    func testIntersectScaledSphere() throws {
        let worldRay = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let s = Sphere()
            .scale(2, 2, 2)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(3))
        XCTAssert(intersections[1].t.isAlmostEqual(7))
    }

    func testIntersectTranslatedSphere() throws {
        let worldRay = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let s = Sphere()
            .translate(5, 0, 0)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 0)
    }

    func testNormalPointOnXAxis() throws {
        let p = Point(1, 0, 0)
        let s = Sphere()
        let actualValue = s.normal(p)
        let expectedValue = Vector(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnYAxis() throws {
        let p = Point(0, 1, 0)
        let s = Sphere()
        let actualValue = s.normal(p)
        let expectedValue = Vector(0, 1, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnZAxis() throws {
        let p = Point(0, 0, 1)
        let s = Sphere()
        let actualValue = s.normal(p)
        let expectedValue = Vector(0, 0, 1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalNonaxialPoint() throws {
        let p = Point(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        let s = Sphere()
        let actualValue = s.normal(p)
        let expectedValue = Vector(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTranslatedSphere() throws {
        let s = Sphere()
            .translate(0, 1, 0)
        let actualValue = s.normal(Point(0, 1.70711, -0.70711))
        let expectedValue = Vector(0, 0.70711, -0.70711)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTransformedSphere() throws {
        let s = Sphere()
            .scale(1, 0.5, 1)
            .rotateY(PI/5)
        let actualValue = s.normal(Point(0, sqrt(2)/2, -sqrt(2)/2))
        let expectedValue = Vector(0, 0.97014, -0.24254)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
