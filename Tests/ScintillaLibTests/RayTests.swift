//
//  RayTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class RayTests: XCTestCase {
    func testPosition() throws {
        let r = Ray(Point(2, 3, 4), Vector(1, 0, 0))
        XCTAssert(r.position(0).isAlmostEqual(Point(2, 3, 4)))
        XCTAssert(r.position(1).isAlmostEqual(Point(3, 3, 4)))
        XCTAssert(r.position(-1).isAlmostEqual(Point(1, 3, 4)))
        XCTAssert(r.position(2.5).isAlmostEqual(Point(4.5, 3, 4)))
    }

    func testTransformTranslation() throws {
        let r = Ray(Point(1, 2, 3), Vector(0, 1, 0))
        let m = Matrix4.translation(3, 4, 5)
        let transformedR = r.transform(m)
        XCTAssert(transformedR.origin.isAlmostEqual(Point(4, 6, 8)))
        XCTAssert(transformedR.direction.isAlmostEqual(Vector(0, 1, 0)))
    }

    func testTransformScaling() throws {
        let r = Ray(Point(1, 2, 3), Vector(0, 1, 0))
        let m = Matrix4.scaling(2, 3, 4)
        let transformedR = r.transform(m)
        XCTAssert(transformedR.origin.isAlmostEqual(Point(2, 6, 12)))
        XCTAssert(transformedR.direction.isAlmostEqual(Vector(0, 3, 0)))
    }
}
