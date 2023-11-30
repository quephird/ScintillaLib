//
//  IntersectionTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class IntersectionTests: XCTestCase {
    func testHitIntersectionsWithAllPositiveTs() throws {
        let s = Sphere()
        let i1 = Intersection(1, s)
        let i2 = Intersection(2, s)
        let intersections = [i2, i1]
        let h = hit(intersections)!
        XCTAssert(h.t.isAlmostEqual(i1.t))
    }

    func testHitIntersectionsWithSomeNegativeTs() throws {
        let s = Sphere()
        let i1 = Intersection(-1, s)
        let i2 = Intersection(1, s)
        let intersections = [i2, i1]
        let h = hit(intersections)!
        XCTAssert(h.t.isAlmostEqual(i2.t))
    }

    func testHitIntersectionsWithAllNegativeTs() throws {
        let s = Sphere()
        let i1 = Intersection(-2, s)
        let i2 = Intersection(-1, s)
        let intersections = [i2, i1]
        let h = hit(intersections)
        XCTAssertNil(h)
    }

    func testHitReturnsLowestNonnegativeIntersection() throws {
        let s = Sphere()
        let i1 = Intersection(5, s)
        let i2 = Intersection(7, s)
        let i3 = Intersection(-3, s)
        let i4 = Intersection(2, s)
        let intersections = [i1, i2, i3, i4]
        let h = hit(intersections)!
        XCTAssert(h.t.isAlmostEqual(i4.t))
    }

    func testHitOnlyConsidersObjectsThatCastShadowsWhenCalledThatWay() throws {
        let s1 = Sphere()
            .castsShadow(false)
        let i1 = Intersection(1, s1)
        let i2 = Intersection(3, s1)
        let s2 = Sphere()
            .translate(3, 0, 0)
        let i3 = Intersection(4, s2)
        let i4 = Intersection(6, s2)
        let intersections = [i1, i2, i3, i4]
        let h = hit(intersections, includeOnlyShadowingObjects: true)!
        XCTAssertEqual(h.shape.id, s2.id)
    }

    let testCamera = Camera(width: 800,
                            height: 600,
                            viewAngle:PI/3,
                            from: Point(0, 1, -1),
                            to: Point(0, 0, 0),
                            up: Vector(0, 1, 0))

    func testPrepareComputationsOutside() async throws {
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let shape = Sphere()
        let world = World {
            testCamera
            shape
        }
        let intersection = Intersection(4, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        XCTAssertEqual(computations.t, intersection.t)
        XCTAssertEqual(computations.object.id, shape.id)
        XCTAssert(computations.point.isAlmostEqual(Point(0, 0, -1)))
        XCTAssert(computations.eye.isAlmostEqual(Vector(0, 0, -1)))
        XCTAssert(computations.normal.isAlmostEqual(Vector(0, 0, -1)))
        XCTAssertEqual(computations.isInside, false)
    }

    func testPrepareComputationsInside() async throws {
        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let shape = Sphere()
        let world = World {
            testCamera
            shape
        }
        let intersection = Intersection(1, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        XCTAssertEqual(computations.t, intersection.t)
        XCTAssertEqual(computations.object.id, shape.id)
        XCTAssert(computations.point.isAlmostEqual(Point(0, 0, 1)))
        XCTAssert(computations.eye.isAlmostEqual(Vector(0, 0, -1)))
        XCTAssert(computations.normal.isAlmostEqual(Vector(0, 0, -1)))
        XCTAssertEqual(computations.isInside, true)
    }

    func testPrepareComputationsShouldComputeOverPoint() async throws {
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let shape = Sphere()
            .translate(0, 0, 1)
        let world = World {
            testCamera
            shape
        }
        let intersection = Intersection(5, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        XCTAssertTrue(computations.overPoint[2] < -EPSILON/2)
        XCTAssertTrue(computations.point[2] > computations.overPoint[2])
    }

    func testPrepareComputationsShouldComputeUnderPoint() async throws {
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let shape = Sphere()
            .translate(0, 0, 1)
        let world = World {
            testCamera
            shape
        }
        let intersection = Intersection(5, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        XCTAssertTrue(computations.underPoint[2] > EPSILON/2)
        XCTAssertTrue(computations.point[2] < computations.underPoint[2])
    }

    func testPrepareComputationsReflected() async throws {
        let shape = Plane()
        let world = World {
            testCamera
            shape
        }
        let ray = Ray(Point(0, 1, -1), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        XCTAssertTrue(computations.reflected.isAlmostEqual(Vector(0, sqrt(2)/2, sqrt(2)/2)))
    }

    func testPrepareComputationsForN1AndN2() async throws {
        let glassSphereA = Sphere()
            .material(.basicMaterial().refractive(1.5))
            .scale(2, 2, 2)
        let glassSphereB = Sphere()
            .material(.basicMaterial().refractive(2.0))
            .translate(0, 0, -0.25)
        let glassSphereC = Sphere()
            .material(.basicMaterial().refractive(2.5))
            .translate(0, 0, 0.25)
        let world = World {
            testCamera
            glassSphereA
            glassSphereB
            glassSphereC
        }

        let ray = Ray(Point(0, 0, -4), Vector(0, 0, 1))
        let allIntersections = [
            Intersection(2, glassSphereA),
            Intersection(2.75, glassSphereB),
            Intersection(3.25, glassSphereC),
            Intersection(4.75, glassSphereB),
            Intersection(5.25, glassSphereC),
            Intersection(6, glassSphereA),
        ]
        let expectedValues = [
            (1.0, 1.5),
            (1.5, 2.0),
            (2.0, 2.5),
            (2.5, 2.5),
            (2.5, 1.5),
            (1.5, 1.0)
        ]

        for index in 0...5 {
            let intersection = allIntersections[index]
            let computations = await intersection.prepareComputations(world, ray, allIntersections)
            let actualValue = (computations.n1, computations.n2)
            let expectedValue = expectedValues[index]
            XCTAssertTrue(actualValue == expectedValue)
        }
    }
}
