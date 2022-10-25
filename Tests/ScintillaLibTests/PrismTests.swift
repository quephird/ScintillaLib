//
//  PrismTests.swift
//  
//
//  Created by Danielle Kefford on 10/22/22.
//

import XCTest
@testable import ScintillaLib

class PrismTests: XCTestCase {
    func testCheckRectangleRayHits() throws {
        let corner = point(0, 0, 0)
        let bottom = vector(1, 0, 0)
        let left = vector(0, 2, 0)

        for ((ox, oy, oz), (dx, dy, dz), expectedT) in [
            ((0.5, 0.5, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.9, 1.9, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.1, 1.9, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.9, 0.1, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.1, 0.1, -1.0), (0.0, 0.0, 1.0), 1.0),
        ] {
            let ray = Ray(point(ox, oy, oz), vector(dx, dy, dz))
            let maybeT = checkRectangle(ray, corner, bottom, left)

            XCTAssertNotNil(maybeT)
            XCTAssertEqual(maybeT!, expectedT)
        }
    }

    func testCheckRectangleRayMisses() throws {
        let corner = point(0, 0, 0)
        let bottom = vector(1, 0, 0)
        let left = vector(0, 2, 0)

        for ((ox, oy, oz), (dx, dy, dz)) in [
            ((1.1, 2.1, -1.0), (0.0, 0.0, 1.0)),
            ((-0.1, 2.1, -1.0), (0.0, 0.0, 1.0)),
            ((1.1, -0.1, -1.0), (0.0, 0.0, 1.0)),
            ((-0.1, -0.1, -1.0), (0.0, 0.0, 1.0)),
        ] {
            let ray = Ray(point(ox, oy, oz), vector(dx, dy, dz))
            let maybeT = checkRectangle(ray, corner, bottom, left)

            XCTAssertNil(maybeT)
        }
    }

    func testIsInsidePolygonForSquare() throws {
        let yPolygon = 1.0
        let xzTuples = [
            (1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)
        ]
        for ((x, y, z), expectedResult) in [
            ((0.0, 1.0, 0.0), true), // Points inside square but in same plane
            ((0.9, 1.0, 0.9), true),
            ((-0.9, 1.0, 0.9), true),
            ((0.9, 1.0, -0.9), true),
            ((-0.9, 1.0, -0.9), true),
            ((1.1, 1.0, 0.9), false), // Points inside square but in same plane
            ((0.9, 1.0, 1.1), false),
            ((-1.1, 1.0, 0.9), false),
            ((0.9, 1.0, -1.1), false),
            ((0.0, 1.1, 0.0), false), // Point off plane
        ] {
            let actualResult = isInsidePolygon(point(x, y, z), xzTuples, yPolygon)
            XCTAssertEqual(actualResult, expectedResult)
        }
    }

    func testIsInsidePolygonForConcaveQuadrilateral() throws {
        let yPolygon = 2.0
        let xzTuples = [
            (1.0, -1.0), (0.0, 1.0), (-1.0, -1.0), (0.0, -0.5)
        ]
        for ((x, y, z), expectedResult) in [
            ((0.0, 2.0, 0.0), true), // Points inside quadrilateral
            ((0.9, 2.0, -0.9), true),
            ((-0.9, 2.0, -0.9), true),
            ((0.0, 2.0, 0.9), true),
            ((0.0, 2.0, -0.6), false), // Points outside quadrilateral
            ((0.0, 2.0, 1.1), false),
            ((1.0, 2.0, -1.1), false),
            ((-1.0, 2.0, -1.1), false),
        ] {
            let actualResult = isInsidePolygon(point(x, y, z), xzTuples, yPolygon)
            XCTAssertEqual(actualResult, expectedResult)
        }
    }
}
