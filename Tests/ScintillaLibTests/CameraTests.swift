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
                            viewTransform: .identity)
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testPixelSizeForVerticalCanvas() throws {
        let camera = Camera(width: 125,
                            height: 200,
                            viewAngle: PI/2,
                            viewTransform: .identity)
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testRayForPixelForCenterOfCanvas() throws {
        let camera = Camera(width: 201, height: 101, viewAngle: PI/2, viewTransform: .identity)
        let ray = camera.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0, 0, -1)))
    }

    func testRayForPixelForCornerOfCanvas() throws {
        let camera = Camera(width: 201, height: 101, viewAngle: PI/2, viewTransform: .identity)
        let ray = camera.rayForPixel(0, 0)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0.66519, 0.33259, -0.66851)))
    }

    func testRayForPixelForTransformedCamera()  throws {
        let transform = Matrix4.rotationY(PI/4)
            .multiply(.translation(0, -2, 5))
        let camera = Camera(width: 201, height: 101, viewAngle: PI/2, viewTransform: transform)
        let ray = camera.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 2, -5)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(sqrt(2)/2, 0, -sqrt(2)/2)))
    }
}
