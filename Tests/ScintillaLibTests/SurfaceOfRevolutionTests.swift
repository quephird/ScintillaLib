//
//  SurfaceOfRevolutionTests.swift
//  
//
//  Created by Danielle Kefford on 10/30/22.
//

import XCTest
@_spi(Testing) import ScintillaLib

class SurfaceOfRevolutionTests: XCTestCase {
    func testSolveForInconsistentMatrixYieldsNoSolution() throws {
        let matrix = [
            [0.0, 1.0, -2.0, 0.0],
            [2.0, 3.0, 0.0, 2.0],
            [-1.0, -2.0, 1.0, -1.0],
        ]
        XCTAssertNil(solve(matrix))
    }

    func testSolveForMatrixWithPivotZeroValueYieldsNoSolution() throws {
        let matrix = [
            [1.0, 0.0, 0.0, 2.0],
            [0.0, 1.0, 0.0, 3.0],
            [0.0, 0.0, 0.0, 4.0],
        ]
        XCTAssertNil(solve(matrix))
    }

    func testSolveForConsistentMatrixWithSolution() throws {
        let matrix = [
            [2.0, 1.0, -1.0, 8.0],
            [-3.0, -1.0, 2.0, -11.0],
            [-2.0, 1.0, 2.0, -3.0],
        ]
        let expectedSolution = [2.0, 3.0, -1.0]
        let actualSolution = solve(matrix)
        XCTAssertEqual(actualSolution, expectedSolution)
    }

    func testMakeCubicSplineMatrix() throws {
        let expectedValue = [
            [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 21.0],
            [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0],
            [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0],
            [0.0, 0.0, 0.0, 0.0, 8.0, 4.0, 2.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 8.0, 4.0, 2.0, 1.0, 0.0, 0.0, 0.0, 0.0, 24.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 27.0, 9.0, 3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 18.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 27.0, 9.0, 3.0, 1.0, 18.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 64.0, 16.0, 4.0, 1.0, 16.0],
            [3.0, 2.0, 1.0, 0.0, -3.0, -2.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 12.0, 4.0, 1.0, 0.0, -12.0, -4.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 27.0, 6.0, 1.0, 0.0, -27.0, -6.0, -1.0, 0.0, 0.0],
            [6.0, 2.0, 0.0, 0.0, -6.0, -2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 12.0, 2.0, 0.0, 0.0, -12.0, -2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 18.0, 2.0, 0.0, 0.0, -18.0, -2.0, 0.0, 0.0, 0.0],
            [0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 24.0, 2.0, 0.0, 0.0, 0.0],
        ]

        let points = [(0.0, 21.0), (1.0, 24.0), (2.0, 24.0), (3.0, 18.0), (4.0, 16.0)]
        let actualValue = makeCubicSplineMatrix(points)
        XCTAssertEqual(actualValue, expectedValue)
    }

    func testMakePiecewiseCubicSplineFunction() throws {
        let points = [(0.0, 21.0), (1.0, 24.0), (2.0, 24.0), (3.0, 18.0), (4.0, 16.0)]
        let coefficients = [
            (-0.3035714285718569, 0.0, 3.3035714285708337, 21.0),
            (-1.4821428571427404, 3.5357142857136594, -0.2321428571417954, 22.178571428570876),
            (3.2321428571428363, -24.749999999999797, 56.33928571428511, -15.53571428571372),
            (-1.4464285714285712, 17.35714285714287, -69.98214285714292, 110.78571428571432)
        ]

        let f = makePiecewiseCubicSplineFunction(points, coefficients)!
        XCTAssertTrue(f(0).isAlmostEqual(21.0))
        XCTAssertTrue(f(1).isAlmostEqual(24.0))
        XCTAssertTrue(f(2).isAlmostEqual(24.0))
        XCTAssertTrue(f(3).isAlmostEqual(18.0))
        XCTAssertTrue(f(4).isAlmostEqual(16.0))
    }

    func testLocalIntersectForSurfaceOfRevolution() throws {
        let yzPoints = [(0.0, 2.0), (2.0, 1.5), (3.0, 0.5), (6.0, 0.5)]
        let shape = SurfaceOfRevolution(yzPoints)

        let ray = Ray(Point(0.0, 2.0, -2.0), Vector(0.0, 0.0, 1.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertEqual(intersections.count, 2)
        XCTAssertTrue(intersections[0].t.isAlmostEqual(0.5))
        XCTAssertTrue(intersections[1].t.isAlmostEqual(3.5))
    }

    func testLocalIntersectForSurfaceOfRevolutionHitsBothCaps() throws {
        let yzPoints = [(0.0, 2.0), (1.0, 1.0), (2.0, 0.5)]
        let shape = SurfaceOfRevolution(yzPoints, true)

        let ray = Ray(Point(0.0, -1.0, 0.0), Vector(0.0, 1.0, 0.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertTrue(intersections[0].t.isAlmostEqual(1.0))
        XCTAssertTrue(intersections[1].t.isAlmostEqual(3.0))
    }


    func testLocalIntersectForSurfaceOfRevolutionHitsOneCapAndWall() throws {
        let yzPoints = [(0.0, 2.0), (1.0, 1.0), (2.0, 0.5)]
        let shape = SurfaceOfRevolution(yzPoints, true)

        let ray = Ray(Point(-0.70711, -0.70711, 0.0), Vector(0.70711, 0.70711, 0.0))
        let intersections = shape.localIntersect(ray)
        XCTAssertTrue(intersections[0].t.isAlmostEqual(1.0))
        XCTAssertTrue(intersections[1].t.isAlmostEqual(2.41421))
    }

    func testLocalNormalForSurfaceOfRevolutionForCylinderEquivalent() throws {
        let yzPoints = [(0.0, 2.0), (1.0, 2.0), (2.0, 2.0)]
        let shape = SurfaceOfRevolution(yzPoints)

        let testPoint = Point(0.0, 1.0, -2.0)
        let actualValue = shape.localNormal(testPoint)
        let expectedValue = Vector(0.0, 0.0, -1.0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testLocalNormalForSurfaceOfRevolutionForConeEquivalent() throws {
        let yzPoints = [(0.0, 2.0), (1.0, 1.0), (2.0, 0.0)]
        let shape = SurfaceOfRevolution(yzPoints)

        let testPoint = Point(0.0, 1.0, -1.0)
        let actualValue = shape.localNormal(testPoint)
        let expectedValue = Vector(0.0, 0.70711, -0.70711)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testLocalNormalForSurfaceOfRevolutionForCurvedShape() throws {
        let yzPoints = [(0.0, 1.0), (1.0, 2.0), (2.0, 1.0)]
        let shape = SurfaceOfRevolution(yzPoints)

        let testPoint = Point(0.0, 0.5, -1.6875)
        let actualValue = shape.localNormal(testPoint)
        let expectedValue = Vector(0.0, -0.74741, -0.66436)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }
}
