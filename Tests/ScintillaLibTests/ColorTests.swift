//
//  ColorTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/19/21.
//

import XCTest

class ColorTests: XCTestCase {
    func testAdd() throws {
        let c1 = Color(0.9, 0.6, 0.75)
        let c2 = Color(0.7, 0.1, 0.25)
        XCTAssert(c1.add(c2).isAlmostEqual(Color(1.6, 0.7, 1.0)))
    }

    func testSubtract() throws {
        let c1 = Color(0.9, 0.6, 0.75)
        let c2 = Color(0.7, 0.1, 0.25)
        let actualValue = c1.subtract(c2)
        let expectedValue = Color(0.2, 0.5, 0.5)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testMultipleScalar() throws {
        let c = Color(0.2, 0.3, 0.4)
        XCTAssert(c.multiplyScalar(2).isAlmostEqual(Color(0.4, 0.6, 0.8)))
    }

    func testHadamard() throws {
        let c1 = Color(1.0, 0.2, 0.4)
        let c2 = Color(0.9, 1.0, 0.1)
        let expectedValue = Color(0.9, 0.2, 0.04)
        XCTAssert(c1.hadamard(c2).isAlmostEqual(expectedValue))
    }
}
