//
//  PatternTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/24/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class PatternTests: XCTestCase {
    func testStripePatternIsConstantInY() throws {
        let pattern = Striped(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 1, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 2, 0)).isAlmostEqual(.white))
    }

    func testStripePatternIsConstantInZ() throws {
        let pattern = Striped(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 1)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 2)).isAlmostEqual(.white))
    }

    func testStripePatternAlternatestInX() throws {
        let pattern = Striped(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0.9, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(1, 0, 0)).isAlmostEqual(.black))
        XCTAssertTrue(pattern.colorAt(Point(-0.1, 0, 0)).isAlmostEqual(.black))
        XCTAssertTrue(pattern.colorAt(Point(-1, 0, 0)).isAlmostEqual(.black))
        XCTAssertTrue(pattern.colorAt(Point(-1.1, 0, 0)).isAlmostEqual(.white))
    }

    func testStripePatternWithObjectTransformation() throws {
        let shape = Sphere()
            .scale(2, 2, 2)
        let pattern = Striped(.white, .black, .identity)
        let actualValue = pattern.colorAt(shape, Point(1.5, 0, 0))
        let expectedValue = Color.white
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testStripePatternWithPatternTransformation() throws {
        let shape = Sphere()
        let pattern = Striped(.white, .black, .scaling(2, 2, 2))
        let actualValue = pattern.colorAt(shape, Point(1.5, 0, 0))
        let expectedValue = Color.white
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testStripePatternWithBothTransformations() throws {
        let shape = Sphere()
            .scale(2, 2, 2)
        let pattern = Striped(.white, .black, .translation(0.5, 0, 0))
        let actualValue = pattern.colorAt(shape, Point(2.5, 0, 0))
        let expectedValue = Color.white
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testGradientPatternInterpolatesBetweenColors() throws {
        let pattern = Gradient(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0.25, 0, 0)).isAlmostEqual(Color(0.75, 0.75, 0.75)))
        XCTAssertTrue(pattern.colorAt(Point(0.5, 0, 0)).isAlmostEqual(Color(0.5, 0.5, 0.5)))
        XCTAssertTrue(pattern.colorAt(Point(0.75, 0, 0)).isAlmostEqual(Color(0.25, 0.25, 0.25)))
    }

    func testCheckered3DPatternShouldRepeatInX() throws {
        let pattern = Checkered3D(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0.99, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(1.01, 0, 0)).isAlmostEqual(.black))
    }

    func testCheckered3DPatternShouldRepeatInY() throws {
        let pattern = Checkered3D(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 0.99, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 1.01, 0)).isAlmostEqual(.black))
    }

    func testCheckered3DPatternShouldRepeatInZ() throws {
        let pattern = Checkered3D(.white, .black, .identity)
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 0.99)).isAlmostEqual(.white))
        XCTAssertTrue(pattern.colorAt(Point(0, 0, 1.01)).isAlmostEqual(.black))
    }
}
