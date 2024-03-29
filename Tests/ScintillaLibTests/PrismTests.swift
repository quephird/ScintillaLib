//
//  PrismTests.swift
//  
//
//  Created by Danielle Kefford on 10/22/22.
//

import XCTest
@_spi(Testing) import ScintillaLib

class PrismTests: XCTestCase {
    func testCheckRectangleRayHits() throws {
        let corner = Point(0, 0, 0)
        let bottom = Vector(1, 0, 0)
        let left = Vector(0, 2, 0)

        for ((ox, oy, oz), (dx, dy, dz), expectedT) in [
            ((0.5, 0.5, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.9, 1.9, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.1, 1.9, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.9, 0.1, -1.0), (0.0, 0.0, 1.0), 1.0),
            ((0.1, 0.1, -1.0), (0.0, 0.0, 1.0), 1.0),
        ] {
            let ray = Ray(Point(ox, oy, oz), Vector(dx, dy, dz))
            let maybeT = checkRectangle(ray, corner, bottom, left)

            XCTAssertNotNil(maybeT)
            XCTAssertEqual(maybeT!, expectedT)
        }
    }

    func testCheckRectangleRayMisses() throws {
        let corner = Point(0, 0, 0)
        let bottom = Vector(1, 0, 0)
        let left = Vector(0, 2, 0)

        for ((ox, oy, oz), (dx, dy, dz)) in [
            ((1.1, 2.1, -1.0), (0.0, 0.0, 1.0)),
            ((-0.1, 2.1, -1.0), (0.0, 0.0, 1.0)),
            ((1.1, -0.1, -1.0), (0.0, 0.0, 1.0)),
            ((-0.1, -0.1, -1.0), (0.0, 0.0, 1.0)),
        ] {
            let ray = Ray(Point(ox, oy, oz), Vector(dx, dy, dz))
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
            let actualResult = isInsidePolygon(Point(x, y, z), xzTuples, yPolygon)
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
            let actualResult = isInsidePolygon(Point(x, y, z), xzTuples, yPolygon)
            XCTAssertEqual(actualResult, expectedResult)
        }
    }

    func testLocalIntersectTriangularPrism() throws {
        let prism = Prism(bottomY: -1.0,
                          topY: 1.0,
                          xzPoints: [
                            (1.0, -1.0),
                            (0.0, 1.0),
                            (-1.0, -1.0),
                          ])
        for ((ox, oy, oz), (dx, dy, dz), expectedTs) in [
            ((0.5, 0.0, -2.0), (0.0, 0.0, 1.0), [1.0, 2.0]), // Ray entering through front side
            ((-2.0, 0.0, 0.0), (1.0, 0.0, 0.0), [1.5, 2.5]), // Ray entering from the left
            ((0.0, -2.0, 0.0), (0.0, 1.0, 0.0), [1.0, 3.0]), // Ray entering from the bottom center
            ((-1.0, 3.0, 0.0), (1.0, -2.0, 0.0), [1.0, 1.5]), // Ray entering from the top at an angle
        ] {
            let ray = Ray(Point(ox, oy, oz), Vector(dx, dy, dz))
            let actualTs = prism
                .localIntersect(ray)
                .sorted { (i1, i2) in
                    i1.t < i2.t
                }
                .map { i in
                    i.t
                }
            XCTAssertEqual(actualTs, expectedTs)
        }
    }

    func testLocalIntersectPrismFromConcaveQuad() throws {
        let prism = Prism(bottomY: -1.0,
                          topY: 1.0,
                          xzPoints: [
                            (1.0, -1.0),
                            (0.0, 1.0),
                            (-1.0, -1.0),
                            (0.0, 0.0),
                          ])

        for ((ox, oy, oz), (dx, dy, dz), expectedTs) in [
            ((-2.0, 0.0, -0.5), (1.0, 0.0, 0.0), [1.25, 1.5, 2.5, 2.75]), // Ray entering through left side, four hits
            ((-2.0, 0.0, 0.5), (1.0, 0.0, 0.0), [1.75, 2.25]), // Ray entering through left side, only two hits
            ((-0.625, 2.0, -0.5), (0.0, -1.0, 0.0), [1.0, 3.0]), // Ray entering through top side, two hits
            ((-1.0, 2.0, -0.5), (0.0, -1.0, 0.0), []), // Ray originating from top left, total miss
        ] {
            let ray = Ray(Point(ox, oy, oz), Vector(dx, dy, dz))
            let actualTs = prism
                .localIntersect(ray)
                .sorted { (i1, i2) in
                    i1.t < i2.t
                }
                .map { i in
                    i.t
                }
            XCTAssertEqual(actualTs, expectedTs)
        }

    }

    func testLocalNormalForTriangularPrism() {
        let prism = Prism(bottomY: -1.0,
                          topY: 1.0,
                          xzPoints: [
                            (1.0, -1.0),
                            (0.0, 1.0),
                            (-1.0, -1.0)
                          ])

        for ((ix, iy, iz), (nx, ny, nz)) in [
            ((0.0, 0.0, -1.0), (0.0, 0.0, -1.0)), // Middle front side
            ((0.5, 0.0, 0.0), (0.89443, 0.0, 0.44721)), // Right side
            ((-0.5, 0.0, 0.0), (-0.89443, 0.0, 0.44721)), // Left side
            ((0.0, 1.0, 0.0), (0.0, 1.0, 0.0)), // Top side
            ((0.0, -1.0, 0.0), (0.0, -1.0, 0.0)), // Bottom side
        ] {
            let actualNormal = prism.localNormal(Point(ix, iy, iz))
            let expectedNormal = Vector(nx, ny, nz)
            XCTAssertTrue(actualNormal.isAlmostEqual(expectedNormal))
        }
    }
}
