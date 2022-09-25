//
//  IntersectionTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/22/21.
//

import XCTest
@testable import ScintillaLib

class IntersectionTests: XCTestCase {
    func testHitIntersectionsWithAllPositiveTs() throws {
        let s = Sphere(.basicMaterial())
        let i1 = Intersection(1, s)
        let i2 = Intersection(2, s)
        var intersections = [i2, i1]
        let h = hit(&intersections)!
        XCTAssert(h.t.isAlmostEqual(i1.t))
    }

    func testHitIntersectionsWithSomeNegativeTs() throws {
        let s = Sphere(.basicMaterial())
        let i1 = Intersection(-1, s)
        let i2 = Intersection(1, s)
        var intersections = [i2, i1]
        let h = hit(&intersections)!
        XCTAssert(h.t.isAlmostEqual(i2.t))
    }

    func testHitIntersectionsWithAllNegativeTs() throws {
        let s = Sphere(.basicMaterial())
        let i1 = Intersection(-2, s)
        let i2 = Intersection(-1, s)
        var intersections = [i2, i1]
        let h = hit(&intersections)
        XCTAssertNil(h)
    }

    func testHitReturnsLowestNonnegativeIntersection() throws {
        let s = Sphere(.basicMaterial())
        let i1 = Intersection(5, s)
        let i2 = Intersection(7, s)
        let i3 = Intersection(-3, s)
        let i4 = Intersection(2, s)
        var intersections = [i1, i2, i3, i4]
        let h = hit(&intersections)!
        XCTAssert(h.t.isAlmostEqual(i4.t))
    }

    func testPrepareComputationsOutside() throws {
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let shape = Sphere(.basicMaterial())
        let intersection = Intersection(4, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        XCTAssertEqual(computations.t, intersection.t)
        XCTAssertEqual(computations.object.id, shape.id)
        XCTAssert(computations.point.isAlmostEqual(point(0, 0, -1)))
        XCTAssert(computations.eye.isAlmostEqual(vector(0, 0, -1)))
        XCTAssert(computations.normal.isAlmostEqual(vector(0, 0, -1)))
        XCTAssertEqual(computations.isInside, false)
    }

    func testPrepareComputationsInside() throws {
        let ray = Ray(point(0, 0, 0), vector(0, 0, 1))
        let shape = Sphere(.basicMaterial())
        let intersection = Intersection(1, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        XCTAssertEqual(computations.t, intersection.t)
        XCTAssertEqual(computations.object.id, shape.id)
        XCTAssert(computations.point.isAlmostEqual(point(0, 0, 1)))
        XCTAssert(computations.eye.isAlmostEqual(vector(0, 0, -1)))
        XCTAssert(computations.normal.isAlmostEqual(vector(0, 0, -1)))
        XCTAssertEqual(computations.isInside, true)
    }

    func testPrepareComputationsShouldComputeOverPoint() throws {
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let shape = Sphere(.basicMaterial())
            .translate(0, 0, 1)
        let intersection = Intersection(5, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        XCTAssertTrue(computations.overPoint[2] < -EPSILON/2)
        XCTAssertTrue(computations.point[2] > computations.overPoint[2])
    }

    func testPrepareComputationsShouldComputeUnderPoint() throws {
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let shape = Sphere(.basicMaterial())
            .translate(0, 0, 1)
        let intersection = Intersection(5, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        XCTAssertTrue(computations.underPoint[2] > EPSILON/2)
        XCTAssertTrue(computations.point[2] < computations.underPoint[2])
    }

    func testPrepareComputationsReflected() throws {
        let shape = Plane(.basicMaterial())
        let ray = Ray(point(0, 1, -1), vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        XCTAssertTrue(computations.reflected.isAlmostEqual(vector(0, sqrt(2)/2, sqrt(2)/2)))
    }

    func testPrepareComputationsForN1AndN2() throws {
        let glassSphereA = Sphere(.basicMaterial().refractive(1.5))
            .scale(2, 2, 2)
        let glassSphereB = Sphere(.basicMaterial().refractive(2.0))
            .translate(0, 0, -0.25)
        let glassSphereC = Sphere(.basicMaterial().refractive(2.5))
            .translate(0, 0, 0.25)

        let ray = Ray(point(0, 0, -4), vector(0, 0, 1))
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
            let computations = intersection.prepareComputations(ray, allIntersections)
            let actualValue = (computations.n1, computations.n2)
            let expectedValue = expectedValues[index]
            XCTAssertTrue(actualValue == expectedValue)
        }
    }
}
