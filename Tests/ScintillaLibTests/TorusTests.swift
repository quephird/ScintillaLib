//
//  TorusTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 9/8/22.
//

import XCTest
@testable import ScintillaLib

class TorusTests: XCTestCase {
    func areAlmostEqual(_ hits1: [Double], _ hits2: [Double]) -> Bool {
        if hits1.count != hits2.count {
            return false
        }

        let hits1Sorted = hits1.sorted()
        let hits2Sorted = hits2.sorted()

        for (index, root1) in hits1Sorted.enumerated() {
            if !root1.isAlmostEqual(hits2Sorted[index]) {
                return false
            }
        }

        return true
    }

    func testIntersectFourHits() throws {
        let r = Ray(point(-5, 0, 0), vector(1, 0, 0))
        let torus = Torus(3, 1)
        let intersections = torus.intersect(r)
        let expectedHits = [1.0, 3.0, 7.0, 9.0]
        let actualHits = intersections.map { intersection in
            return intersection.t
        }
        XCTAssert(areAlmostEqual(actualHits, expectedHits))
    }

    func testIntersectThreeHitsWithOneHitTangent() throws {
        let r = Ray(point(-5, 0, -2), vector(1, 0, 0))
        let torus = Torus(3, 1)
        let intersections = torus.intersect(r)
        let expectedHits = [1.53590, 5.0, 8.46410]
        let actualHits = intersections.map { intersection in
            return intersection.t
        }
        XCTAssert(areAlmostEqual(actualHits, expectedHits))
    }

    func testIntersectTwoHits() throws {
        let r = Ray(point(-5, 0, -3), vector(1, 0, 0))
        let torus = Torus(3, 1)
        let intersections = torus.intersect(r)
        let expectedHits = [2.35425, 7.64575]
        let actualHits = intersections.map { intersection in
            return intersection.t
        }
        XCTAssert(areAlmostEqual(actualHits, expectedHits))
    }

    func testIntersectOneHitTangentRay() throws {
        let r = Ray(point(-5, 0, -4), vector(1, 0, 0))
        let torus = Torus(3, 1)
        let intersections = torus.intersect(r)
        let expectedHits = [5.0]
        let actualHits = intersections.map { intersection in
            return intersection.t
        }
        XCTAssert(areAlmostEqual(actualHits, expectedHits))
    }

    func testIntersectMiss() throws {
        let r = Ray(point(-5, 0, -5), vector(1, 0, 0))
        let torus = Torus(3, 1)
        let intersections = torus.intersect(r)
        XCTAssert(intersections.isEmpty)
    }
}
