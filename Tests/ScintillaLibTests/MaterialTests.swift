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
        let light = PointLight(point(0, 0, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.9, 1.9, 1.9)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeOffsetFortyFiveDegrees() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, sqrt(2)/2, -sqrt(2)/2)
        let normal = vector(0, 0, -1)
        let light = PointLight(point(0, 0, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.0, 1.0, 1.0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightOffsetFortyFiveDegrees() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = PointLight(point(0, 10, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(0.7364, 0.7364, 0.7364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeInPathOfReflectionVector() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, -sqrt(2)/2, -sqrt(2)/2)
        let normal = vector(0, 0, -1)
        let light = PointLight(point(0, 10, -10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.6364, 1.6364, 1.6364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightBehindSurface() throws {
        let m = Material.basicMaterial()
        let shape = Sphere(m)
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = PointLight(point(0, 0, 10), Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingSurfaceInShadow() throws {
        let light = PointLight(point(0, 0, -10), Color(1, 1, 1))
        let position = point(0, 0, 0)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let material = Material.basicMaterial()
        let shape = Sphere(material)
        let actualValue = material.lighting(light, shape, position, eye, normal, 0.0)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingWithPattern() throws {
        let striped = Striped(Color(1, 1, 1), Color(0, 0, 0), .identity)
        let material = Material(.pattern(striped), 1.0, 0.0, 0.0, 200, 0.0, 0.0, 0.0)
        let shape = Sphere(material)
        let eye = vector(0, 0, -1)
        let normal = vector(0, 0, -1)
        let light = PointLight(point(0, 0, -10), Color(1, 1, 1))
        let color1 = material.lighting(light, shape, point(0.9, 0, 0), eye, normal, 1.0)
        XCTAssertTrue(color1.isAlmostEqual(.white))
        let color2 = material.lighting(light, shape, point(1.1, 0, 0), eye, normal, 1.0)
        XCTAssertTrue(color2.isAlmostEqual(.black))
    }

    func testLightUsesIntensityToAttenuateColor() throws {
        let light = PointLight(point(0, 0, -10))
        let shape = Sphere(.solidColor(.white)
            .ambient(0.1)
            .diffuse(0.9)
            .specular(0.0)
            .refractive(0.0)
        )
        let point  = point(0, 0, -1)
        let eye    = vector(0, 0, -1)
        let normal = vector(0, 0, -1)

        let testCases = [
            (1.0, Color(1, 1, 1)),
            (0.5, Color(0.55, 0.55, 0.55)),
            (0.0, Color(0.1, 0.1, 0.1))
        ]
        for (intensity, expectedLighting) in testCases {
            let actualLighting = shape.material.lighting(light, shape, point, eye, normal, intensity)
            XCTAssertTrue(actualLighting.isAlmostEqual(expectedLighting))
        }
    }

    func testLightingSamplesAreaLight() throws {
        let areaLight = AreaLight(
            point(-0.5, -0.5, -5),
            Color(1, 1, 1),
            vector(1, 0, 0), 2,
            vector(0, 1, 0), 2,
            NoJitter())
        let material: Material = .solidColor(.white)
            .ambient(0.1)
            .diffuse(0.9)
            .specular(0.0)
        let shape = Sphere(material)
        let eye = point(0, 0, -5)

        let testCases = [
            (point(0, 0, -1), Color(0.9965, 0.9965, 0.9965)),
            (point(0, 0.7071, -0.7071), Color(0.62318, 0.62318, 0.62318)),
        ]
        for (point, expectedColor) in testCases {
            let eyeV = eye.subtract(point).normalize()
            let normalV = vector(point.x, point.y, point.z)
            let actualColor = material.lighting(areaLight, shape, point, eyeV, normalV, 1.0)
            XCTAssert(actualColor.isAlmostEqual(expectedColor))
        }
    }
}
