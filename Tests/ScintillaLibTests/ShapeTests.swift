//
//  ShapeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/30/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class ShapeTests: XCTestCase {
    let testCamera = Camera(width: 800,
                            height: 600,
                            viewAngle:PI/3,
                            from: Point(0, 1, -1),
                            to: Point(0, 0, 0),
                            up: Vector(0, 1, 0))

    func testWorldToObjectForNestedObject() async throws {
        let s = Sphere()
            .translate(5, 0, 0)

        let world = World {
            testCamera
            Group {
                Group {
                    s
                }
                    .scale(2, 2, 2)
            }
                .rotateY(PI/2)
        }

        let actualValue = await s.worldToObject(world, Point(-2, 0, -10))
        let expectedValue = Point(0, 0, -1)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testObjectToWorldForNestedObject() async throws {
        let s = Sphere()
            .translate(5, 0, 0)

        let world = World {
            testCamera
            Group {
                Group {
                    s
                }
                    .scale(1, 2, 3)
            }
                .rotateY(PI/2)
        }

        let actualValue = await s.objectToWorld(world, Vector(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3))
        let expectedValue = Vector(0.28571, 0.42857, -0.85714)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalForNestedObject() async throws {
        let s = Sphere()
            .translate(5, 0, 0)

        let world = World {
            testCamera
            Group {
                Group {
                    s
                }
                    .scale(1, 2, 3)
            }
                .rotateY(PI/2)
        }

        let actualValue = await s.normal(world, Point(1.7321, 1.1547, -5.5774))
        let expectedValue = Vector(0.28570, 0.42854, -0.85716)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }
}
