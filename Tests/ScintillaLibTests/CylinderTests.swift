//
//  CylinderTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/27/21.
//

import XCTest
@testable import ScintillaLib

class CylinderTests: XCTestCase {
    func testLocalIntersectMisses() throws {
        let cylinder = Cylinder()

        let testCases = [
            (point(1, 0, 0), vector(0, 1, 0)),
            (point(0, 0, 0), vector(0, 1, 0)),
            (point(0, 0, -5), vector(1, 1, 1)),
        ]

        for (origin, direction) in testCases {
            let ray = Ray(origin, direction)
            let allIntersections = cylinder.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, 0)
        }
    }

    func testLocalIntersectHitsWalls() throws {
        let cylinder = Cylinder()

        let testCases = [
            (point(1, 0, -5), vector(0, 0, 1), [5.0]),
            (point(0, 0, -5), vector(0, 0, 1), [4.0, 6.0]),
            (point(0.5, 0, -5), vector(0.1, 1, 1), [6.80798, 7.08872]),
        ]

        for (origin, direction, expectedTs) in testCases {
            let ray = Ray(origin, direction.normalize())
            let allIntersections = cylinder.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, expectedTs.count)

            let actualTs = allIntersections.map({intersection in
                intersection.t
            })
            XCTAssertTrue(zip(actualTs, expectedTs).allSatisfy({(actualT, expectedT) in
                actualT.isAlmostEqual(expectedT)
            }))
        }
    }

    func testLocalIntersectHitsCaps() throws {
        let cylinder = Cylinder(1, 2, true)

        let testCases = [
            (point(0, 3, 0), vector(0, -1, 0), 2),
            (point(0, 3, -2), vector(0, -1, 2), 2),
            (point(0, 4, -2), vector(0, -1, 1), 2),
            (point(0, 0, -2), vector(0, 1, 2), 2),
            (point(0, -1, -2), vector(0, 1, 1), 2),
        ]

        for (origin, direction, expectedCount) in testCases {
            let ray = Ray(origin, direction.normalize())
            let allIntersections = cylinder.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, expectedCount)
        }
    }

    func testLocalIntersectTruncated() throws {
        let cylinder = Cylinder(1, 2)

        let testCases = [
            (point(0, 1.5, 0), vector(0.1, 1, 0), 0),
            (point(0, 3, -5), vector(0, 0, 1), 0),
            (point(0, 0, -5), vector(0, 0, 1), 0),
            (point(0, 2, -5), vector(0, 0, 1), 0),
            (point(0, 1, -5), vector(0, 0, 1), 0),
            (point(0, 1.5, -2), vector(0, 0, 1), 2)
        ]

        for (origin, direction, expectedCount) in testCases {
            let localRay = Ray(origin, direction)
            let allIntersections = cylinder.localIntersect(localRay)
            XCTAssertTrue(allIntersections.count == expectedCount)
        }
    }

    func testLocalNormalOnWalls() throws {
        let cylinder = Cylinder()

        let testCases = [
            (point(1, 0, 0), vector(1, 0, 0)),
            (point(0, 5, -1), vector(0, 0, -1)),
            (point(0, -2, 1), vector(0, 0, 1)),
            (point(-1, 1, 0), vector(-1, 0, 0)),
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cylinder.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }

    func testLocalNormalOnCaps() throws {
        let cylinder = Cylinder(1, 2, true)

        let testCases = [
            (point(0, 1, 0), vector(0, -1, 0)),
            (point(0.5, 1, 0), vector(0, -1, 0)),
            (point(0, 1, 0.5), vector(0, -1, 0)),
            (point(0, 2, 0), vector(0, 1, 0)),
            (point(0.5, 2, 0), vector(0, 1, 0)),
            (point(0, 2, 0.5), vector(0, 1, 0)),
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cylinder.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }
}
