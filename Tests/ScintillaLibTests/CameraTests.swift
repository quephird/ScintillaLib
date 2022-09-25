//
//  CameraTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@testable import ScintillaLib

class CameraTests: XCTestCase {
    func testPixelSizeForHorizontalCanvas() throws {
        let camera = Camera(200, 125, PI/2, .identity)
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testPixelSizeForVerticalCanvas() throws {
        let camera = Camera(125, 200, PI/2, .identity)
        let actualValue = camera.pixelSize
        let expectedValue = 0.01
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
