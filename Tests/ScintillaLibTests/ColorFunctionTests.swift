//
//  ColorFunctionTests.swift
//  
//
//  Created by Danielle Kefford on 12/19/22.
//

import XCTest
@_spi(Testing) import ScintillaLib

class ColorFunctionTests: XCTestCase {
    func testColorFunctionReturnsExpectedColors() throws {
        func f(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
            (abs(sin(x)), abs(sin(y)), abs(sin(z)))
        }
        let colorFunction = ColorFunction(.rgb, f)

        XCTAssertTrue(colorFunction.colorAt(Point(0, 0, 0)).isAlmostEqual(Color.black))
        XCTAssertTrue(colorFunction.colorAt(Point(PI/2.0, 0, 0)).isAlmostEqual(Color(1.0, 0.0, 0.0)))
        XCTAssertTrue(colorFunction.colorAt(Point(PI, 0, 0)).isAlmostEqual(Color.black))
        XCTAssertTrue(colorFunction.colorAt(Point(PI/2.0, PI/2.0, PI/2.0)).isAlmostEqual(Color.white))
    }

    func testColorFunctionRespectsTransforms() throws {
        func f(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
            (abs(sin(x)), 0.0, 0.0)
        }
        let colorFunction = ColorFunction(.rgb, f).transform(.scaling(0.5, 1.0, 1.0))

        let shape = Cube()
        XCTAssertTrue(colorFunction.colorAt(shape, Point(0, 0, 0)).isAlmostEqual(Color.black))
        XCTAssertTrue(colorFunction.colorAt(shape, Point(PI/4.0, 0, 0)).isAlmostEqual(Color(1.0, 0.0, 0.0)))
    }
}
