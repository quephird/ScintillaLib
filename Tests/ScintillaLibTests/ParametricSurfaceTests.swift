//
//  ParametricSurfaceTests.swift
//
//
//  Created by Danielle Kefford on 11/17/23.
//

import XCTest
@_spi(Testing) import ScintillaLib

class ParametricSurfaceTests: XCTestCase {
    func testLocalIntersectParametricallyDefinedSphereShouldReturnOneHit() throws {
        let bottomLeftFront = (-1.1, -1.1, -1.1)
        let topRightBack = (1.1, 1.1, 1.1)
        let shape = ParametricSurface(
            bottomLeftFront, topRightBack,
            (0, 2*PI), (0, 2*PI),
            0.001, 1,
            { (u, v) in cos(u)*sin(v) },
            { (u, v) in sin(u)*sin(v) },
            { (u, v) in cos(v) })

        let ray = Ray(Point(0.0, 0.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 1)
        // Note that the accuracy affects the t value here
        XCTAssert(intersections[0].t.isAlmostEqual(0.99823))
    }

    func testLocalIntersectSphereWithSmallerBoundingSphereShouldMiss() throws {
        let boundingSphere = Sphere().scale(0.99, 0.99, 0.99)
        let shape = ParametricSurface(
            boundingSphere,
            (0, 2*PI), (0, 2*PI),
            0.001, 1,
            { (u, v) in cos(u)*sin(v) },
            { (u, v) in sin(u)*sin(v) },
            { (u, v) in cos(v) })

        let ray = Ray(Point(0.0, 0.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 0)
    }

    func testLocalIntersectParametricallyDefinedTorusShouldReturnOneHit() throws {
        let bottomLeftFront = (-3.1, -1.1, -3.1)
        let topRightBack = (3.1, 1.1, 3.1)
        let shape = ParametricSurface(
            bottomLeftFront, topRightBack,
            (0, 2*PI), (0, 2*PI),
            0.001, 1,
            { (u, v) in (2 + cos(v))*cos(u) },
            { (u, v) in sin(v) },
            { (u, v) in (2 + cos(v))*sin(u) })

        let ray = Ray(Point(0.0, 0.0, -4.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 1)
        // Note that the accuracy affects the t value here
        XCTAssert(intersections[0].t.isAlmostEqual(0.99823))
    }

    func testLocalIntersectSpiralShouldReturnOneHit() throws {
        let bottomLeftFront = (-3.1, -3.1, -3.1)
        let topRightBack = (3.1, 3.1, 3.1)
        let shape = ParametricSurface(
            bottomLeftFront, topRightBack,
            (0, 2*PI), (0, 2*PI),
            0.001, 1,
            { (u, v) in (2.0 + cos(v))*cos(u) },
            { (u, v) in sin(v) + u },
            { (u, v) in (2.0 + cos(v))*sin(u) })

        let ray = Ray(Point(0.0, PI/2.0, -4.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 1)
        // Note that the accuracy affects the t value here
        XCTAssert(intersections[0].t.isAlmostEqual(4.99823))
    }
}
