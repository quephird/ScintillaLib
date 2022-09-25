//
//  PpmTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/20/21.
//

import XCTest
@testable import ScintillaLib

class PpmTests: XCTestCase {
    func testPpmHeader() throws {
        let c = Canvas(5, 3)
        let ppmHeader = c.ppmHeader()
        let expectedValue = """
P3
5 3
255
"""
       XCTAssertEqual(ppmHeader, expectedValue)
    }

    func testPpmForTinyCanvas() throws {
        var c = Canvas(5, 3)
        let c1 = Color(1.5, 0, 0)
        let c2 = Color(0, 0.5, 0)
        let c3 = Color(-0.5, 0, 1)
        c.setPixel(0, 0, c1)
        c.setPixel(2, 1, c2)
        c.setPixel(4, 2, c3)
        let ppm = c.toPPM()
        let expectedValue = """
P3
5 3
255
255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 255

"""
        XCTAssertEqual(ppm, expectedValue)
    }

    func testPpmForWideCanvas() throws {
        let width = 10
        let height = 2
        var canvas = Canvas(width, height)
        let color = Color(1.0, 0.8, 0.6)
        for y in 0...height-1 {
            for x in 0...width-1 {
                canvas.setPixel(x, y, color)
            }
        }
        let ppm = canvas.toPPM()
        let expectedValue = """
P3
10 2
255
255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
153 255 204 153 255 204 153 255 204 153 255 204 153
255 204 153 255 204 153 255 204 153 255 204 153 255 204 153 255 204
153 255 204 153 255 204 153 255 204 153 255 204 153

"""
        XCTAssertEqual(ppm, expectedValue)
    }
}
