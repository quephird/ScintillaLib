//
//  LightTests.swift
//
//
//  Created by Danielle Kefford on 10/11/22.
//

import XCTest
@_spi(Testing) import ScintillaLib

class LightTests: XCTestCase {
    func testAreaLightIsCreatedProperly() throws {
        let areaLight = AreaLight(corner: Point(0, 0, 0),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(2, 0, 0),
                                  uSteps: 4,
                                  vVec: Vector(0, 0, 1),
                                  vSteps: 2)

        XCTAssertEqual(areaLight.samples, 8)
        XCTAssert(areaLight.uVec.isAlmostEqual(Vector(0.5, 0.0, 0.0)))
        XCTAssert(areaLight.vVec.isAlmostEqual(Vector(0.0, 0.0, 0.5)))
        XCTAssert(areaLight.position.isAlmostEqual(Point(1.0, 0.0, 0.5)))
    }

    func testFindingAPointOnAnAreaLight() throws {
        var areaLight = AreaLight(corner: Point(0, 0, 0),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(2, 0, 0),
                                  uSteps: 4,
                                  vVec: Vector(0, 0, 1),
                                  vSteps: 2,
                                  jitter: NoJitter())

        let testCases = [
            (0, 0, Point(0.25, 0, 0.25)),
            (1, 0, Point(0.75, 0, 0.25)),
            (0, 1, Point(0.25, 0, 0.75)),
            (2, 0, Point(1.25, 0, 0.25)),
            (3, 1, Point(1.75, 0, 0.75)),
        ]
        for (u, v, expectedPoint) in testCases {
            let actualPoint = areaLight.pointAt(u, v)
            XCTAssert(actualPoint.isAlmostEqual(expectedPoint))
        }
    }

    func testFindingAPointOnAnAreaLightWithJitter() throws {
        var areaLight = AreaLight(corner: Point(0, 0, 0),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(2, 0, 0),
                                  uSteps: 4,
                                  vVec: Vector(0, 0, 1),
                                  vSteps: 2,
                                  jitter: PseudorandomJitter([0.3, 0.7]))

        let testCases = [
            (0, 0, Point(0.15, 0, 0.35)),
            (1, 0, Point(0.65, 0, 0.35)),
            (0, 1, Point(0.15, 0, 0.85)),
            (2, 0, Point(1.15, 0, 0.35)),
            (3, 1, Point(1.65, 0, 0.85)),
        ]
        for (u, v, expectedPoint) in testCases {
            let actualPoint = areaLight.pointAt(u, v)
            XCTAssert(actualPoint.isAlmostEqual(expectedPoint))
        }
    }
}
