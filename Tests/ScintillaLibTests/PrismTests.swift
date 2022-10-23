//
//  PrismTests.swift
//  
//
//  Created by Danielle Kefford on 10/22/22.
//

import XCTest
@testable import ScintillaLib

class PrismTests: XCTestCase {
    func testCheckRectangle() throws {
        let corner = point(0, 0, 0)
        let bottom = vector(1, 0, 0)
        let left = vector(0, 1, 0)
        let ray = Ray(point(0.5, 0.5, -1), vector(0.0, 0.0, 1.0))
        let maybeT = checkRectangle(ray, corner, bottom, left)

        XCTAssertNotNil(maybeT)
    }
}
