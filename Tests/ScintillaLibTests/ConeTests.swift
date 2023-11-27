//
//  ConeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/28/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class ConeTests: XCTestCase {
    func testLocalIntersectWithRayThatHitsWalls() throws {
        let cone = Cone()

        let testCases = [
            (Point(0, 0, -5), Vector(0, 0, 1), [5.0]),
            (Point(0, 0, -5), Vector(1, 1, 1), [8.66025]),
            (Point(1, 1, -5), Vector(-0.5, -1, 1), [4.55006, 49.44994]),
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
        let ray = Ray(Point(0, 0, -1), Vector(0, 1, 1).normalize())
        let allIntersections = cone.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 1)
        XCTAssertTrue(allIntersections[0].t.isAlmostEqual(0.35355))
    }

    func testLocalIntersectWithRayThatHitsCaps() throws {
        let cone = Cone(bottomY: -0.5, topY: 0.5, isCapped: true)

        let testCases = [
            (Point(0, 0, -5), Vector(0, 1, 0), 0),
            (Point(0, 0, -0.25), Vector(0, 1, 1), 2),
            (Point(0, 0, -0.25), Vector(0, 1, 0), 4),
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
            (Point(0, 0, 0), Vector(0, 0, 0)),
            (Point(1, 1, 1), Vector(1, -sqrt(2), 1)),
            (Point(-1, -1, 0), Vector(-1, 1, 0)),
        ]

        for (localPoint, expectedValue) in testCases {
            let actualValue = cone.localNormal(localPoint)
            XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
        }
    }
}
