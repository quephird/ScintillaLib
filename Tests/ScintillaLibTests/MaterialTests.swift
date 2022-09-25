//
//  MaterialTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@testable import ScintillaLib

class MaterialTests: XCTestCase {
    func testLightingEyeBetweenLightAndSurface() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 0, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, false)
        let expectedValue = Color(1.9, 1.9, 1.9)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeOffsetFortyFiveDegrees() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, sqrt(2)/2, -sqrt(2)/2)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 0, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, false)
        let expectedValue = Color(1.0, 1.0, 1.0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightOffsetFortyFiveDegrees() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 10, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, false)
        let expectedValue = Color(0.7364, 0.7364, 0.7364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeInPathOfReflectionVector() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, -sqrt(2)/2, -sqrt(2)/2)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 10, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, false)
        let expectedValue = Color(1.6364, 1.6364, 1.6364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightBehindSurface() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 0, 10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, false)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingSurfaceInShadow() throws {
        let light = Light(point(0, 0, -10), Color(1, 1, 1))
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let isShadowed = true
        let material = Material.basicMaterial()
        let shape = Sphere(material)
        let actualValue = material.lighting(light, shape, position, eye, normal, isShadowed)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingWithPattern() throws {
        let striped = Striped(Color(1, 1, 1), Color(0, 0, 0), .identity)
        let material = Material(.pattern(striped), 1.0, 0.0, 0.0, 200, 0.0, 0.0, 0.0)
        let shape = Sphere(material)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = Light(point(0, 0, -10), Color(1, 1, 1))
        let color1 = material.lighting(light, shape, point(0.9, 0, 0), eye, normal, false)
        XCTAssertTrue(color1.isAlmostEqual(.white))
        let color2 = material.lighting(light, shape, point(1.1, 0, 0), eye, normal, false)
        XCTAssertTrue(color2.isAlmostEqual(.black))
    }
}
