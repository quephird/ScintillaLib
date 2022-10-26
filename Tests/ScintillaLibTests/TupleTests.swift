//
//  TupleTests.swift
//  TupleTests
//
//  Created by Danielle Kefford on 11/19/21.
//

import XCTest
@testable import ScintillaLib

class Tuple4Tests: XCTestCase {
    func testAdd() throws {
        let t1 = Point(3.0, -2.0, 5.0)
        let t2 = Vector(-2.0, 3.0, 1.0)
        XCTAssert(t1.add(t2).isAlmostEqual(Point(1.0, 1.0, 6.0)))
    }

    func testSubtractTwoPoints() throws {
        let p1 = Point(3.0, 2.0, 1.0)
        let p2 = Point(5.0, 6.0, 7.0)
        let expectedValue = Vector(-2.0, -4.0, -6.0)
        let actualValue = p1.subtract(p2)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testSubtractVectorFromPoint() throws {
        let p = Point(3, 2, 1)
        let v = Vector(5, 6, 7)
        XCTAssert(p.subtract(v).isAlmostEqual(Point(-2, -4, -6)))
    }

    func testSubtractTwoVectors() throws {
        let v1 = Vector(3, 2, 1)
        let v2 = Vector(5, 6, 7)
        XCTAssert(v1.subtract(v2).isAlmostEqual(Vector(-2, -4, -6)))
    }

    func testNegate() throws {
        let t = Vector(1.0, -2.0, 3.0)
        XCTAssert(t.negate().isAlmostEqual(Vector(-1.0, 2.0, -3.0)))
    }

    func testMultiplyScalar() throws {
        let t = Vector(1.0, -2.0, 3.0)
        XCTAssert(t.multiply(3.5).isAlmostEqual(Vector(3.5, -7.0, 10.5)))
    }

    func testMultiplyScalarFraction() throws {
        let t = Vector(1.0, -2.0, 3.0)
        XCTAssert(t.multiply(0.5).isAlmostEqual(Vector(0.5, -1.0, 1.5)))
    }

    func testDivideScalar() throws {
        let t = Vector(1.0, -2.0, 3.0)
        XCTAssert(t.divide(2).isAlmostEqual(Vector(0.5, -1.0, 1.5)))
    }

    func testMagnitude() throws {
        let v = Vector(1, 2, 3)
        XCTAssertEqual(v.magnitude(), 14.0.squareRoot())
    }

    func testNormalize() throws {
        let v1 = Vector(4, 0, 0)
        XCTAssert(v1.normalize().isAlmostEqual(Vector(1, 0, 0)))

        let v2 = Vector(1, 2, 3)
        let normalizedV2 = v2.normalize()
        XCTAssert(normalizedV2.isAlmostEqual(Vector(0.26726, 0.53452, 0.80178)))
        XCTAssert(normalizedV2.magnitude().isAlmostEqual(1.0))
    }

    func testDot() throws {
        let v1 = Vector(1, 2, 3)
        let v2 = Vector(2, 3, 4)
        XCTAssertEqual(v1.dot(v2), 20.0)
    }

    func testCross() throws {
        let v1 = Vector(1, 2, 3)
        let v2 = Vector(2, 3, 4)
        let actualValue1 = v1.cross(v2)
        let expectedValue1 = Vector(-1, 2, -1)
        XCTAssert(actualValue1.isAlmostEqual(expectedValue1))

        let actualValue2 = v2.cross(v1)
        let expectedValue2 = Vector(1, -2, 1)
        XCTAssert(actualValue2.isAlmostEqual(expectedValue2))
    }

    func testReflectFortyFiveDegrees() throws {
        let v = Vector(1, -1, 0)
        let n = Vector(0, 1, 0)
        let actualValue = v.reflect(n)
        let expectedValue = Vector(1, 1, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testReflectSlantedSurface() throws {
        let v = Vector(0, -1, 0)
        let n = Vector(sqrt(2)/2, sqrt(2)/2, 0)
        let actualValue = v.reflect(n)
        let expectedValue = Vector(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
