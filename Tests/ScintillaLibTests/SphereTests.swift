//
//  SphereTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class SphereTests: XCTestCase {
    func testIntersectTangent() throws {
        let r = Ray(Point(0, 1, -5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 1)
        XCTAssert(intersections[0].t.isAlmostEqual(5.0))
    }

    func testIntersectMiss() throws {
        let r = Ray(Point(0, 2, -5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 0)
    }

    func testIntersectInside() throws {
        let r = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(1.0))
    }

    func testIntersectSphereBehind() throws {
        let r = Ray(Point(0, 0, 5), Vector(0, 0, 1))
        let s = Sphere()
        let intersections = s.intersect(r)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(-6.0))
        XCTAssert(intersections[1].t.isAlmostEqual(-4.0))
    }

    func testIntersectScaledSphere() throws {
        let worldRay = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let s = Sphere()
            .scale(2, 2, 2)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(3))
        XCTAssert(intersections[1].t.isAlmostEqual(7))
    }

    func testIntersectTranslatedSphere() throws {
        let worldRay = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let s = Sphere()
            .translate(5, 0, 0)
        let intersections = s.intersect(worldRay)
        XCTAssertEqual(intersections.count, 0)
    }

    let testCamera = Camera(width: 800,
                            height: 600,
                            viewAngle:PI/3,
                            from: Point(0, 1, -1),
                            to: Point(0, 0, 0),
                            up: Vector(0, 1, 0))

    func testNormalPointOnXAxis() async throws {
        let p = Point(1, 0, 0)
        let sphere = Sphere()
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, p)
        let expectedValue = Vector(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnYAxis() async throws {
        let p = Point(0, 1, 0)
        let sphere = Sphere()
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, p)
        let expectedValue = Vector(0, 1, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalPointOnZAxis() async throws {
        let p = Point(0, 0, 1)
        let sphere = Sphere()
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, p)
        let expectedValue = Vector(0, 0, 1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalNonaxialPoint() async throws {
        let p = Point(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        let sphere = Sphere()
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, p)
        let expectedValue = Vector(sqrt(3)/3, sqrt(3)/3, sqrt(3)/3)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTranslatedSphere() async throws {
        let sphere = Sphere()
            .translate(0, 1, 0)
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, Point(0, 1.70711, -0.70711))
        let expectedValue = Vector(0, 0.70711, -0.70711)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testNormalTransformedSphere() async throws {
        let sphere = Sphere()
            .scale(1, 0.5, 1)
            .rotateY(PI/5)
        let world = World {
            testCamera
            sphere
        }
        let assignedSphere = await world.shapes[0]
        let actualValue = await assignedSphere.normal(world, Point(0, sqrt(2)/2, -sqrt(2)/2))
        let expectedValue = Vector(0, 0.97014, -0.24254)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}
