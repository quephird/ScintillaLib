//
//  MaterialTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class MaterialTests: XCTestCase {
    func testLightingEyeBetweenLightAndSurface() throws {
        let m = SolidColor.basicMaterial()
        let shape = Sphere().material(m)
        let position = Point(0, 0, 0)
        let eye = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 0, -10), color: Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.9, 1.9, 1.9)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeOffsetFortyFiveDegrees() throws {
        let m = SolidColor.basicMaterial()
        let shape = Sphere().material(m)
        let position = Point(0, 0, 0)
        let eye = Vector(0, sqrt(2)/2, -sqrt(2)/2)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 0, -10), color: Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.0, 1.0, 1.0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightOffsetFortyFiveDegrees() throws {
        let m = SolidColor.basicMaterial()
        let shape = Sphere().material(m)
        let position = Point(0, 0, 0)
        let eye = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 10, -10), color: Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(0.7364, 0.7364, 0.7364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingEyeInPathOfReflectionVector() throws {
        let m = SolidColor.basicMaterial()
        let shape = Sphere().material(m)
        let position = Point(0, 0, 0)
        let eye = Vector(0, -sqrt(2)/2, -sqrt(2)/2)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 10, -10), color: Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(1.6364, 1.6364, 1.6364)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingLightBehindSurface() throws {
        let m = SolidColor.basicMaterial()
        let shape = Sphere().material(m)
        let position = Point(0, 0, 0)
        let eye = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 0, 10), color: Color(1, 1, 1))
        let actualValue = m.lighting(light, shape, position, eye, normal, 1.0)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingSurfaceInShadow() throws {
        let light = PointLight(position: Point(0, 0, -10), color: Color(1, 1, 1))
        let position = Point(0, 0, 0)
        let eye = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let material = SolidColor.basicMaterial()
        let shape = Sphere().material(material)
        let actualValue = material.lighting(light, shape, position, eye, normal, 0.0)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testLightingWithPattern() throws {
        let material = Striped(Color(1, 1, 1), Color(0, 0, 0), .identity)
            .ambient(1.0)
            .diffuse(0.0)
            .specular(0.0)
            .refractive(0.0)
        let shape = Sphere().material(material)
        let eye = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let light = PointLight(position: Point(0, 0, -10), color: Color(1, 1, 1))
        let color1 = material.lighting(light, shape, Point(0.9, 0, 0), eye, normal, 1.0)
        XCTAssertTrue(color1.isAlmostEqual(.white))
        let color2 = material.lighting(light, shape, Point(1.1, 0, 0), eye, normal, 1.0)
        XCTAssertTrue(color2.isAlmostEqual(.black))
    }

    func testLightUsesIntensityToAttenuateColor() throws {
        let light = PointLight(position: Point(0, 0, -10))
        let shape = Sphere()
            .material(.solidColor(1, 1, 1)
                .ambient(0.1)
                .diffuse(0.9)
                .specular(0.0)
                .refractive(0.0))
        let point  = Point(0, 0, -1)
        let eye    = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)

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
        let areaLight = AreaLight(corner: Point(-0.5, -0.5, -5),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(1, 0, 0),
                                  uSteps: 2,
                                  vVec: Vector(0, 1, 0),
                                  vSteps: 2,
                                  jitter: NoJitter())
        let material: Material = .solidColor(1, 1, 1)
            .ambient(0.1)
            .diffuse(0.9)
            .specular(0.0)
        let shape = Sphere().material(material)
        let eye = Point(0, 0, -5)

        let testCases = [
            (Point(0, 0, -1), Color(0.9965, 0.9965, 0.9965)),
            (Point(0, 0.7071, -0.7071), Color(0.62318, 0.62318, 0.62318)),
        ]
        for (point, expectedColor) in testCases {
            let eyeV = eye.subtract(point).normalize()
            let normalV = Vector(point.x, point.y, point.z)
            let actualColor = material.lighting(areaLight, shape, point, eyeV, normalV, 1.0)
            XCTAssert(actualColor.isAlmostEqual(expectedColor))
        }
    }

    func testColorIsAttenuatedForALightWithAFadeDistance() throws {
        let light = PointLight(position: Point(0, 0, -10), fadeDistance: 5)
        let material: Material = .solidColor(1, 1, 1)
            .ambient(0.1)
            .diffuse(0.9)
            .specular(0.0)
        let shape = Sphere().material(material)
        let point  = Point(0, 0, -1)
        let eye    = Vector(0, 0, -1)
        let normal = Vector(0, 0, -1)
        let intensity = 1.0

        let actualLighting = shape.material.lighting(light, shape, point, eye, normal, intensity)
        let expectedLighting = Color(0.47170, 0.47170, 0.47170)
        XCTAssertTrue(actualLighting.isAlmostEqual(expectedLighting))
    }
}
