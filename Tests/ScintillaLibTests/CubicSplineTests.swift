//
//  CubicSplineTests.swift
//  
//
//  Created by Danielle Kefford on 10/30/22.
//

import XCTest
@testable import ScintillaLib

class CubicSplineTests: XCTestCase {
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
}
