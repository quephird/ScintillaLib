//
//  ShapeTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/30/21.
//

import XCTest
@testable import ScintillaLib

class ShapeTests: XCTestCase {
    func testWorldToObjectForNestedObject() throws {
        let s = Sphere()
            .translate(5, 0, 0)

        let group = Group {
            Group {
                s
            }
                .scale(2, 2, 2)
        }
            .rotateY(PI/2)

        let actualValue = s.worldToObject(Point(-2, 0, -10))
        let expectedValue = Point(0, 0, -1)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testObjectToWorldForNestedObject() throws {
        let s = Sphere()
            .translate(5, 0, 0)
        let group = Group {
            Group {
                s
            }
                .scale(1, 2, 3)
        }
            .rotateY(PI/2)

        let actualValue = s.objectToWorld(Vector(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3))
        let expectedValue = Vector(0.28571, 0.42857, -0.85714)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalForNestedObject() throws {
        let s = Sphere()
            .translate(5, 0, 0)
        let group = Group {
            Group {
                s
            }
                .scale(1, 2, 3)
        }
            .rotateY(PI/2)

        let actualValue = s.normal(Point(1.7321, 1.1547, -5.5774))
        let expectedValue = Vector(0.28570, 0.42854, -0.85716)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }
}
