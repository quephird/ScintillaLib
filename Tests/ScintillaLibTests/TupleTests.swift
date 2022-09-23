//
//  TupleTests.swift
//  TupleTests
//
//  Created by Danielle Kefford on 11/19/21.
//

import XCTest

class Tuple4Tests: XCTestCase {
    func testAdd() throws {
        let t1 = Tuple4(3.0, -2.0, 5.0, 1.0)
        let t2 = Tuple4(-2.0, 3.0, 1.0, 0.0)
        XCTAssert(t1.add(t2).isAlmostEqual(Tuple4(1.0, 1.0, 6.0, 1.0)))
    }

    func testSubtractTwoPoints() throws {
        let p1 = point(3.0, 2.0, 1.0)
        let p2 = point(5.0, 6.0, 7.0)
        XCTAssert(p1.subtract(p2).isAlmostEqual(vector(-2.0, -4.0, -6.0)))
    }

    func testSubtractVectorFromPoint() throws {
        let p = point(3, 2, 1)
        let v = vector(5, 6, 7)
        XCTAssert(p.subtract(v).isAlmostEqual(point(-2, -4, -6)))
    }

    func testSubtractTwoVectors() throws {
        let v1 = vector(3, 2, 1)
        let v2 = vector(5, 6, 7)
        XCTAssert(v1.subtract(v2).isAlmostEqual(vector(-2, -4, -6)))
    }

    func testNegate() throws {
        let t = Tuple4(1.0, -2.0, 3.0, -4.0)
        XCTAssert(t.negate().isAlmostEqual(Tuple4(-1.0, 2.0, -3.0, 4.0)))
    }

    func testMultiplyScalar() throws {
        let t = Tuple4(1.0, -2.0, 3.0, -4.0)
        XCTAssert(t.multiplyScalar(3.5).isAlmostEqual(Tuple4(3.5, -7.0, 10.5, -14.0)))
    }

    func testMultiplyScalarFraction() throws {
        let t = Tuple4(1.0, -2.0, 3.0, -4.0)
        XCTAssert(t.multiplyScalar(0.5).isAlmostEqual(Tuple4(0.5, -1.0, 1.5, -2.0)))
    }

    func testDivideScalar() throws {
        let t = Tuple4(1.0, -2.0, 3.0, -4.0)
        XCTAssert(t.divideScalar(2).isAlmostEqual(Tuple4(0.5, -1.0, 1.5, -2.0)))
    }

    func testMagnitude() throws {
        let v = vector(1, 2, 3)
        XCTAssertEqual(v.magnitude(), 14.0.squareRoot())
    }

    func testNormalize() throws {
        let v1 = vector(4, 0, 0)
        XCTAssert(v1.normalize().isAlmostEqual(vector(1, 0, 0)))

        let v2 = vector(1, 2, 3)
        let normalizedV2 = v2.normalize()
        XCTAssert(normalizedV2.isAlmostEqual(vector(0.26726, 0.53452, 0.80178)))
        XCTAssert(normalizedV2.magnitude().isAlmostEqual(1.0))
    }

    func testDot() throws {
        let v1 = vector(1, 2, 3)
        let v2 = vector(2, 3, 4)
        XCTAssertEqual(v1.dot(v2), 20.0)
    }

    func testCross() throws {
        let v1 = vector(1, 2, 3)
        let v2 = vector(2, 3, 4)
        XCTAssert(v1.cross(v2).isAlmostEqual(vector(-1, 2, -1)))
        XCTAssert(v2.cross(v1).isAlmostEqual(vector(1, -2, 1)))
    }

    func testReflectFortyFiveDegrees() throws {
        let v = vector(1, -1, 0)
        let n = vector(0, 1, 0)
        let actualValue = v.reflect(n)
        let expectedValue = vector(1, 1, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testReflectSlantedSurface() throws {
        let v = vector(0, -1, 0)
        let n = vector(sqrt(2)/2, sqrt(2)/2, 0)
        let actualValue = v.reflect(n)
        let expectedValue = vector(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
