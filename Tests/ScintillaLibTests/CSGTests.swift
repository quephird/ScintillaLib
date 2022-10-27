//
//  CSGTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 12/2/21.
//

import XCTest
@testable import ScintillaLib

class CSGTests: XCTestCase {
    func testFilterIntersections() throws {
        let s1 = Sphere()
        let s2 = Cube()
        let allIntersections = [
            Intersection(1, s1),
            Intersection(2, s2),
            Intersection(3, s1),
            Intersection(4, s2),
        ]

        let testCases: [(ScintillaLib.Operation, Int, Int)] = [
            (.union, 0, 3),
            (.intersection, 1, 2),
            (.difference, 0, 1),
        ]
        for (operation, firstIndex, secondIndex) in testCases {
            let csg = CSG(operation, s1, s2)
            let filteredIntersections = csg.filterIntersections(allIntersections)
            XCTAssertEqual(filteredIntersections.count, 2)
            XCTAssertTrue(filteredIntersections[0].t == allIntersections[firstIndex].t)
            XCTAssertTrue(filteredIntersections[1].t == allIntersections[secondIndex].t)
        }
    }

    func testLocalIntersectWithRayThatMisses() throws {
        let s1 = Sphere()
        let s2 = Cube()
        let csg = CSG(.union, s1, s2)
        let ray = Ray(Point(0, 2, -5), Vector(0, 0, 1))
        let allIntersections = csg.localIntersect(ray)
        XCTAssertTrue(allIntersections.isEmpty)
    }

    func testLocalIntersectWithRayThatHits() throws {
        let s1 = Sphere()
        let s2 = Sphere()
            .translate(0, 0, 0.5)
        let csg = CSG(.union, s1, s2)
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let allIntersections = csg.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 2)
        XCTAssertTrue(allIntersections[0].t.isAlmostEqual(4))
        XCTAssertEqual(allIntersections[0].shape.id, s1.id)
        XCTAssertTrue(allIntersections[1].t.isAlmostEqual(6.5))
        XCTAssertEqual(allIntersections[1].shape.id, s2.id)
    }
}
