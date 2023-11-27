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
}
