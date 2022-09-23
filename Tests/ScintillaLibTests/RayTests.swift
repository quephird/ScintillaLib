//
//  RayTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest

class RayTests: XCTestCase {
    func testPosition() throws {
        let r = Ray(point(2, 3, 4), vector(1, 0, 0))
        XCTAssert(r.position(0).isAlmostEqual(point(2, 3, 4)))
        XCTAssert(r.position(1).isAlmostEqual(point(3, 3, 4)))
        XCTAssert(r.position(-1).isAlmostEqual(point(1, 3, 4)))
        XCTAssert(r.position(2.5).isAlmostEqual(point(4.5, 3, 4)))
    }

    func testTransformTranslation() throws {
        let r = Ray(point(1, 2, 3), vector(0, 1, 0))
        let m = Matrix4.translation(3, 4, 5)
        let transformedR = r.transform(m)
        XCTAssert(transformedR.origin.isAlmostEqual(point(4, 6, 8)))
        XCTAssert(transformedR.direction.isAlmostEqual(vector(0, 1, 0)))
    }

    func testTransformScaling() throws {
        let r = Ray(point(1, 2, 3), vector(0, 1, 0))
        let m = Matrix4.scaling(2, 3, 4)
        let transformedR = r.transform(m)
        XCTAssert(transformedR.origin.isAlmostEqual(point(2, 6, 12)))
        XCTAssert(transformedR.direction.isAlmostEqual(vector(0, 3, 0)))
    }
}
