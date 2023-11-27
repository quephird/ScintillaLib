//
//  ImplicitSurfaceTests.swift
//  
//
//  Created by Danielle Kefford on 11/2/22.
//

import XCTest
@_spi(Testing) import ScintillaLib

class ImplicitSurfaceTests: XCTestCase {
    func testLocalIntersectImplicitlyDefinedSphereShouldReturnTwoHits() throws {
        let bottomFrontLeft = (-1.1, -1.1, -1.1)
        let topBackRight = (1.1, 1.1, 1.1)
        let shape = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight) { x, y, z in
            x*x + y*y + z*z - 1.0
        }
        let ray = Ray(Point(0.0, 0.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        XCTAssert(intersections[0].t.isAlmostEqual(1.0))
        XCTAssert(intersections[1].t.isAlmostEqual(3.0))
    }

    func testLocalIntersectRingSurfaceWithTwoBlobsShouldReturnFourHits() throws {
        let bottomFrontLeft = (-3.0, -3.0, -3.0)
        let topBackRight = (3.0, 3.0, 3.0)
        let shape = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight) { x, y, z in
            4.0*(x*x*x*x + (y*y + z*z)*(y*y + z*z)) + 20.0*x*x*(y*y + z*z) - 20.0*(x*x + y*y + z*z) + 20.0
        }
        let ray = Ray(Point(-5.0, 0.0, 0.0), Vector(1.0, 0.0, 0.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 4)
        XCTAssert(intersections[0].t.isAlmostEqual(3.09789))
        XCTAssert(intersections[1].t.isAlmostEqual(3.82443))
        XCTAssert(intersections[2].t.isAlmostEqual(6.17557))
        XCTAssert(intersections[3].t.isAlmostEqual(6.90211))
    }

    func testLocalIntersectRonAvitzursFavoriteShapeShouldReturnFourHits() throws {
        let bottomFrontLeft = (-3.0, -3.0, -3.0)
        let topBackRight = (3.0, 3.0, 3.0)
        let shape = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight) { x, y, z in
            x*x + y*y + z*z + sin(4.0*x) + sin(4.0*y) + sin(4.0*z) - 1.0
        }
        let ray = Ray(Point(5.0, 1.0, 1.0), Vector(-1.0, 0.0, 0.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 4)
        XCTAssert(intersections[0].t.isAlmostEqual(3.77643))
        XCTAssert(intersections[1].t.isAlmostEqual(4.17095))
        XCTAssert(intersections[2].t.isAlmostEqual(4.87005))
        XCTAssert(intersections[3].t.isAlmostEqual(5.76679))
    }

    func testLocalIntersectCylinderWithBoundingBoxShouldMiss() throws {
        let bottomFrontLeft = (-1.01, -1.01, -1.01)
        let topBackRight = (1.01, 1.01, 1.01)
        let shape = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight) { x, y, z in
            x*x + z*z - 1.0
        }
        let ray = Ray(Point(0.0, 1.01, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 0)
    }

    func testLocalIntersectCylinderWithBoundingBoxShouldHitTwice() throws {
        let bottomFrontLeft = (-1.01, -1.01, -1.01)
        let topBackRight = (1.01, 1.01, 1.0)
        let shape = ImplicitSurface(bottomFrontLeft: bottomFrontLeft, topBackRight: topBackRight) { x, y, z in
            x*x + z*z - 1.0
        }
        let ray = Ray(Point(0.0, 0.99, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
    }

    func testLocalIntersectSphereWithBoundingSphereShouldMiss() throws {
        let center = (0.0, 0.0, 0.0)
        let radius = 0.99
        let shape = ImplicitSurface(center: center, radius: radius) { x, y, z in
            x*x + y*y + z*z - 1.0
        }
        let ray = Ray(Point(0.7071, 0.7071, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 0)
    }

    func testLocalIntersectSphereWithBoundingSphereShouldHitTwice() throws {
        let center = (0.0, 0.0, 0.0)
        let radius = 1.01
        let shape = ImplicitSurface(center: center, radius: radius) { x, y, z in
            x*x + y*y + z*z - 1.0
        }
        let ray = Ray(Point(0.7071, 0.7071, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
    }
}
