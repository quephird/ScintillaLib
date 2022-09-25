//
//  SphereTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@testable import ScintillaLib

class SphereTests: XCTestCase {
    func testIntersectTangent() throws {
        let r = Ray(point(0, 1, -5), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 1)
        XCTAssert(intersections[0].t.isAlmostEqual(5.0))
    }

    func testIntersectMiss() throws {
        let r = Ray(point(0, 2, -5), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 0)
    }

    func testIntersectInside() throws {
        let r = Ray(point(0, 0, 0), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(1.0))
    }

    func testIntersectSphereBehind() throws {
        let r = Ray(point(0, 0, 5), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-6.0))
        XCTAssert(intersections[1].t.isAlmostEqual(-4.0))
    }

    func testIntersectScaledSphere() throws {
        let worldRay = Ray(point(0, 0, -5), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
            .scale(2, 2, 2)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(3))
        XCTAssert(intersections[1].t.isAlmostEqual(7))
    }

    func testIntersectTranslatedSphere() throws {
        let worldRay = Ray(point(0, 0, -5), vector(0, 0, 1))
        let s = Sphere(.basicMaterial())
            .translate(5, 0, 0)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 0)
    }

    func testNormalPointOnXAxis() throws {
        let p = point(1, 0, 0)
        let s = Sphere(.basicMaterial())
        let actualValue = s.normal(p)
        let expectedValue = vector(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnYAxis() throws {
        let p = point(0, 1, 0)
        let s = Sphere(.basicMaterial())
        let actualValue = s.normal(p)
        let expectedValue = vector(0, 1, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnZAxis() throws {
        let p = point(0, 0, 1)
        let s = Sphere(.basicMaterial())
        let actualValue = s.normal(p)
        let expectedValue = vector(0, 0, 1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalNonaxialPoint() throws {
        let p = point(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        let s = Sphere(.basicMaterial())
        let actualValue = s.normal(p)
        let expectedValue = vector(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTranslatedSphere() throws {
        let s = Sphere(.basicMaterial())
            .translate(0, 1, 0)
        let actualValue = s.normal(point(0, 1.70711, -0.70711))
        let expectedValue = vector(0, 0.70711, -0.70711)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTransformedSphere() throws {
        let s = Sphere(.basicMaterial())
            .scale(1, 0.5, 1)
            .rotateY(PI/5)
        let actualValue = s.normal(point(0, sqrt(2)/2, -sqrt(2)/2))
        let expectedValue = vector(0, 0.97014, -0.24254)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
