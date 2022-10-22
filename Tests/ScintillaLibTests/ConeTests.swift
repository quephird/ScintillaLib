//
//  ConeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/28/21.
//

import XCTest
@testable import ScintillaLib

class ConeTests: XCTestCase {
    func testLocalIntersectWithRayThatHitsWalls() throws {
        let cone = Cone()

        let testCases = [
            (point(0, 0, -5), vector(0, 0, 1), [5.0]),
            (point(0, 0, -5), vector(1, 1, 1), [8.66025]),
            (point(1, 1, -5), vector(-0.5, -1, 1), [4.55006, 49.44994]),
        ]

        for (origin, direction, expectedTs) in testCases {
            let ray = Ray(origin, direction.normalize())
            let allIntersections = cone.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, expectedTs.count)

            let actualTs = allIntersections.map({intersection in
                intersection.t
            })
            XCTAssertTrue(zip(actualTs, expectedTs).allSatisfy({(actualT, expectedT) in
                actualT.isAlmostEqual(expectedT)
            }))
        }
    }

    func testLocalIntersectWithRayParallelToOneHalf() throws {
        let cone = Cone()
        let ray = Ray(point(0, 0, -1), vector(0, 1, 1).normalize())
        let allIntersections = cone.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 1)
        XCTAssertTrue(allIntersections[0].t.isAlmostEqual(0.35355))
    }

    func testLocalIntersectWithRayThatHitsCaps() throws {
        let cone = Cone(-0.5, 0.5, true)

        let testCases = [
            (point(0, 0, -5), vector(0, 1, 0), 0),
            (point(0, 0, -0.25), vector(0, 1, 1), 2),
            (point(0, 0, -0.25), vector(0, 1, 0), 4),
        ]

        for (origin, direction, expectedCount) in testCases {
            let ray = Ray(origin, direction.normalize())
            let allIntersections = cone.localIntersect(ray)
            XCTAssertEqual(allIntersections.count, expectedCount)
        }
    }

    func testLocalNormalOnWalls() throws {
        let cone = Cone()

        let testCases = [
            (point(0, 0, 0), vector(0, 0, 0)),
            (point(1, 1, 1), vector(1, -sqrt(2), 1)),
            (point(-1, -1, 0), vector(-1, 1, 0)),
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cone.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }
}
