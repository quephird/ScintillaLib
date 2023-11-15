//
//  CanvasTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/20/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class CanvasTests: XCTestCase {
    func testInitCreatesAllWhitePixels() throws {
        let width = 10
        let height = 20
        let c = Canvas(10, 20)
        for x in 0...width-1 {
            for y in 0...height-1 {
                XCTAssert(c.getPixel(x, y).isAlmostEqual(Color(0.0, 0.0, 0.0)))
            }
        }
    }

    func testGetAndSetPixel() throws {
        let width = 10
        let height = 20
        var c = Canvas(width, height)
        let red = Color(1.0, 0.0, 0.0)
        c.setPixel(2, 3, red)
        XCTAssert(c.getPixel(2, 3).isAlmostEqual(red))
    }
}
