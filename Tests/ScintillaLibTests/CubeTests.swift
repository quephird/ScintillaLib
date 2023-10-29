//
//  CubeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/27/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class CubeTests: XCTestCase {
    func testLocalIntersectHits() throws {
        let cube = Cube()

        let testCases = [
            (Point(5, 0.5, 0), Vector(-1, 0, 0), 4.0, 6.0),
            (Point(-5, 0.5, 0), Vector(1, 0, 0), 4.0, 6.0),
            (Point(0.5, 5, 0), Vector(0, -1, 0), 4.0, 6.0),
            (Point(0.5, -5, 0), Vector(0, 1, 0), 4.0, 6.0),
            (Point(0.5, 0, 5), Vector(0, 0, -1), 4.0, 6.0),
            (Point(0.5, 0, -5), Vector(0, 0, 1), 4.0, 6.0),
            (Point(0, 0.5, 0), Vector(0, 0, 1), -1.0, 1.0),
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
        let cube = Cube()

        let testCases = [
            (Point(-2, 0, 0), Vector(0.2673, 0.5345, 0.8018)),
            (Point(0, -2, 0), Vector(0.8018, 0.2673, 0.5345)),
            (Point(0, 0, -2), Vector(0.5345, 0.8018, 0.2673)),
            (Point(2, 0, 2), Vector(0, 0, -1)),
            (Point(0, 2, 2), Vector(0, -1, 0)),
            (Point(2, 2, 0), Vector(-1, 0, 0)),
        ]

        for (origin, direction) in testCases {
            let ray = Ray(origin, direction)
            let allIntersections = cube.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, 0)
        }
    }

    func testLocalNormal() throws {
        let cube = Cube()

        let testCases = [
            (Point(1, 0.5, -0.8), Vector(1, 0, 0)),
            (Point(-1, -0.2, 0.9), Vector(-1, 0, 0)),
            (Point(-0.4, 1, -0.1), Vector(0, 1, 0)),
            (Point(0.3, -1, -0.7), Vector(0, -1, 0)),
            (Point(-0.6, 0.3, 1), Vector(0, 0, 1)),
            (Point(0.4, 0.4, -1), Vector(0, 0, -1)),
            (Point(1, 1, 1), Vector(1, 0, 0)),
            (Point(-1, -1, -1), Vector(-1, 0, 0))
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cube.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }
}
