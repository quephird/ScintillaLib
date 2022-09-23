//
//  CubeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/27/21.
//

import XCTest

class CubeTests: XCTestCase {
    func testLocalIntersectHits() throws {
        let cube = Cube(.basicMaterial())

        let testCases = [
            (point(5, 0.5, 0), vector(-1, 0, 0), 4.0, 6.0),
            (point(-5, 0.5, 0), vector(1, 0, 0), 4.0, 6.0),
            (point(0.5, 5, 0), vector(0, -1, 0), 4.0, 6.0),
            (point(0.5, -5, 0), vector(0, 1, 0), 4.0, 6.0),
            (point(0.5, 0, 5), vector(0, 0, -1), 4.0, 6.0),
            (point(0.5, 0, -5), vector(0, 0, 1), 4.0, 6.0),
            (point(0, 0.5, 0), vector(0, 0, 1), -1.0, 1.0),
        ]

        for (origin, direction, t1, t2) in testCases {
            let ray = Ray(origin, direction)
            let allIntersections = cube.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, 2)
            XCTAssertTrue(allIntersections[0].t.isAlmostEqual(t1))
            XCTAssertTrue(allIntersections[1].t.isAlmostEqual(t2))
        }
    }

    func testLocalIntersectMisses() throws {
        let cube = Cube(.basicMaterial())

        let testCases = [
            (point(-2, 0, 0), vector(0.2673, 0.5345, 0.8018)),
            (point(0, -2, 0), vector(0.8018, 0.2673, 0.5345)),
            (point(0, 0, -2), vector(0.5345, 0.8018, 0.2673)),
            (point(2, 0, 2), vector(0, 0, -1)),
            (point(0, 2, 2), vector(0, -1, 0)),
            (point(2, 2, 0), vector(-1, 0, 0)),
        ]

        for (origin, direction) in testCases {
            let ray = Ray(origin, direction)
            let allIntersections = cube.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, 0)
        }
    }

    func testLocalNormal() throws {
        let cube = Cube(.basicMaterial())

        let testCases = [
            (point(1, 0.5, -0.8), vector(1, 0, 0)),
            (point(-1, -0.2, 0.9), vector(-1, 0, 0)),
            (point(-0.4, 1, -0.1), vector(0, 1, 0)),
            (point(0.3, -1, -0.7), vector(0, -1, 0)),
            (point(-0.6, 0.3, 1), vector(0, 0, 1)),
            (point(0.4, 0.4, -1), vector(0, 0, -1)),
            (point(1, 1, 1), vector(1, 0, 0)),
            (point(-1, -1, -1), vector(-1, 0, 0))
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cube.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }
}
