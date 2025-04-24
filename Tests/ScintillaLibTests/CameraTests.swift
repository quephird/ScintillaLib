//
//  CameraTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class CameraTests: XCTestCase {
    func testPixelSizeForHorizontalCanvas() throws {
        let camera = Camera(width: 200,
                            height: 125,
                            viewAngle: PI/2,
                            from: Point(0, 0, 0),
                            to: Point(0, 0, -1/sin(PI/2)),
                            up: Vector(0, 1, 0))
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testPixelSizeForVerticalCanvas() throws {
        let camera = Camera(width: 200,
                            height: 125,
                            viewAngle: PI/2,
                            from: Point(0, 0, 0),
                            to: Point(0, 0, -1/sin(PI/2)),
                            up: Vector(0, 1, 0))
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testRayForPixelForCenterOfCanvas() async throws {
        let camera = Camera(width: 201,
                            height: 101,
                            viewAngle: PI/2,
                            from: Point(0, 0, 0),
                            to: Point(0, 0, -1/sin(PI/2)),
                            up: Vector(0, 1, 0))
        let ray = camera.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0, 0, -1)))
    }

    func testRayForPixelForCornerOfCanvas() async throws {
        let camera = Camera(width: 201,
                            height: 101,
                            viewAngle: PI/2,
                            from: Point(0, 0, 0),
                            to: Point(0, 0, -1/sin(PI/2)),
                            up: Vector(0, 1, 0))
        let ray = camera.rayForPixel(0, 0)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0.66519, 0.33259, -0.66851)))
    }

    func testRayForPixelForTransformedCamera() async throws {
        let camera = Camera(width: 201,
                            height: 101,
                            viewAngle: PI/2,
                            from: Point(0, 2, -5),
                            to: Point(sqrt(2)/2, 2.0, -5 - sqrt(2)/2),
                            up: Vector(1, 0, 1))

        let ray = camera.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 2, -5)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(sqrt(2)/2, 0, -sqrt(2)/2)))
    }
}
