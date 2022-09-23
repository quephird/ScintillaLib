//
//  MathTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 9/8/22.
//

import XCTest

class MathTests: XCTestCase {
    func areAlmostEqual(_ roots1: [Double], _ roots2: [Double]) -> Bool {
        if roots1.count != roots2.count {
            return false
        }

        let roots1Sorted = roots1.sorted()
        let roots2Sorted = roots2.sorted()

        for (index, root1) in roots1Sorted.enumerated() {
            if !root1.isAlmostEqual(roots2Sorted[index]) {
                return false
            }
        }

        return true
    }

    func testQuadraticWithTwoDistinctRoots() throws {
        let actualRoots = solveQuadratic(1, -3, 2)
        let expectedRoots = [1.0, 2.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuadraticWithOneDoubleRoot() throws {
        let actualRoots = solveQuadratic(1, -4, 4)
        let expectedRoots = [2.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuadraticWithNoRoots() throws {
        let actualRoots = solveQuadratic(1, 0, 1)
        let expectedRoots: [Double] = []
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testCubicWithThreeDistinctRoots() throws {
        let actualRoots = solveCubic(1, -6, 11, -6)
        let expectedRoots = [1.0, 2.0, 3.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testCubicWithOneSingleRootAndOneDoubleRoot() throws {
        let actualRoots = solveCubic(1, -5, 8, -4)
        let expectedRoots = [1.0, 2.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testCubicWithOneRoot() throws {
        let actualRoots = solveCubic(1, 4, -12, -80)
        let expectedRoots = [4.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithFourDistinctRoots() throws {
        let actualRoots = solveQuartic(1, 2, -13, 2, 1)
        let expectedRoots = [-4.79129, -0.208712, 0.381966, 2.61803]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithTwoSingleRootsAndOneDoubleRoot() throws {
        let actualRoots = solveQuartic(1, -9, 29, -39, 18)
        let expectedRoots = [1.0, 2.0, 3.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithTwoDoubleRoots() throws {
        let actualRoots = solveQuartic(1, -6, 13, -12, 4)
        let expectedRoots = [1.0, 2.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithTwoSingleRoots() throws {
        let actualRoots = solveQuartic(1, -4, -2, -4, 21)
        print(actualRoots)
        let expectedRoots = [1.58579, 4.41421]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithOneDoubleRoot() throws {
        let actualRoots = solveQuartic(1, -2, 2, -2, 1)
        let expectedRoots = [1.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithOneQuadrupleRoot() throws {
        let actualRoots = solveQuartic(1, -8, 24, -32, 16)
        let expectedRoots = [2.0]
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }

    func testQuarticWithNoRoots() throws {
        let actualRoots = solveQuartic(1, 0, 0, 0, 1)
        let expectedRoots: [Double] = []
        XCTAssert(areAlmostEqual(actualRoots, expectedRoots))
    }
}
