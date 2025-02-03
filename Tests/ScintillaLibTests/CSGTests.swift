//
//  CSGTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 12/2/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

class CSGTests: XCTestCase {
    func testFilterIntersections() throws {
        let s1 = Sphere()
        let s2 = Cube()
        let testCases: [(ScintillaLib.Operation, Int, Int)] = [
            (.union, 0, 3),
            (.intersection, 1, 2),
            (.difference, 0, 1),
        ]

        for (operation, firstIndex, secondIndex) in testCases {
            let csg = CSG(operation, s1, s2)
            let assignedCsg = csg.assignId(id: [0])
            let assignedS1 = assignedCsg.left
            let assignedS2 = assignedCsg.right
            let allIntersections = [
                Intersection(1, assignedS1),
                Intersection(2, assignedS2),
                Intersection(3, assignedS1),
                Intersection(4, assignedS2),
            ]

            let filteredIntersections = assignedCsg.filterIntersections(allIntersections)
            XCTAssertEqual(filteredIntersections.count, 2)
            XCTAssertTrue(filteredIntersections[0].t == allIntersections[firstIndex].t)
            XCTAssertTrue(filteredIntersections[1].t == allIntersections[secondIndex].t)
        }
    }

    func testLocalIntersectWithRayThatMisses() throws {
        let s1 = Sphere()
        let s2 = Cube()
        let csg = CSG(.union, s1, s2)
        let assignedCsg = csg.assignId(id: [0])
        let ray = Ray(Point(0, 2, -5), Vector(0, 0, 1))
        let allIntersections = assignedCsg.localIntersect(ray)
        XCTAssertTrue(allIntersections.isEmpty)
    }

    func testLocalIntersectWithRayThatHits() throws {
        let s1 = Sphere()
        let s2 = Sphere()
            .translate(0, 0, 0.5)
        let csg = CSG(.union, s1, s2)
        let assignedCsg = csg.assignId(id: [0])

        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let allIntersections = assignedCsg.localIntersect(ray)
        XCTAssertEqual(allIntersections.count, 2)
        XCTAssertTrue(allIntersections[0].t.isAlmostEqual(4))
        XCTAssertEqual(allIntersections[0].shape.id, [0, 0])
        XCTAssertTrue(allIntersections[1].t.isAlmostEqual(6.5))
        XCTAssertEqual(allIntersections[1].shape.id, [0, 1])
    }
}
