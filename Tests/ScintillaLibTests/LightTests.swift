//
//  LightTests.swift
//
//
//  Created by Danielle Kefford on 10/11/22.
//

import XCTest
@testable import ScintillaLib

class LightTests: XCTestCase {
    func testAreaLightIsCreatedProperly() throws {
        let areaLight = AreaLight(
            point(0, 0, 0),
            Color(1, 1, 1),
            vector(2, 0, 0), 4,
            vector(0, 0, 1), 2)

        XCTAssertEqual(areaLight.samples, 8)
        XCTAssert(areaLight.uVec.isAlmostEqual(vector(0.5, 0.0, 0.0)))
        XCTAssert(areaLight.vVec.isAlmostEqual(vector(0.0, 0.0, 0.5)))
        XCTAssert(areaLight.position.isAlmostEqual(point(1.0, 0.0, 0.5)))
    }

    func testFindingAPointOnAnAreaLight() throws {
        let areaLight = AreaLight(
            point(0, 0, 0),
            Color(1, 1, 1),
            vector(2, 0, 0), 4,
            vector(0, 0, 1), 2)

        let testCases = [
            (0, 0, point(0.25, 0, 0.25)),
            (1, 0, point(0.75, 0, 0.25)),
            (0, 1, point(0.25, 0, 0.75)),
            (2, 0, point(1.25, 0, 0.25)),
            (3, 1, point(1.75, 0, 0.75)),
        ]
        for (u, v, expectedPoint) in testCases {
            let actualPoint = areaLight.pointAt(u, v)
            XCTAssert(actualPoint.isAlmostEqual(expectedPoint))
        }
    }
}
