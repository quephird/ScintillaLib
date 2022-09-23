//
//  Color.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/19/21.
//

import Foundation

public struct Color {
    var r: Double
    var g: Double
    var b: Double

    static let white = Color(1.0, 1.0, 1.0)
    static let black = Color(0.0, 0.0, 0.0)

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    func add(_ other: Self) -> Self {
        Color(self.r+other.r, self.g+other.g, self.b+other.b)
    }

    func subtract(_ other: Self) -> Self {
        Color(self.r-other.r, self.g-other.g, self.b-other.b)
    }

    func multiplyScalar(_ scalar: Double) -> Self {
        Color(self.r*scalar, self.g*scalar, self.b*scalar)
    }

    func hadamard(_ other: Self) -> Self {
        Color(self.r*other.r, self.g*other.g, self.b*other.b)
    }

    func isAlmostEqual(_ to: Self) -> Bool {
        self.r.isAlmostEqual(to.r) &&
            self.g.isAlmostEqual(to.g) &&
            self.b.isAlmostEqual(to.b)
    }

    func clampAndScale(_ component: Double) -> Int {
        var c: Int
        if component < 0.0 {
            c = 0
        } else if component > 1.0 {
            c = 255
        } else {
            var cTemp = component*255
            cTemp.round()
            c = Int(cTemp)
        }
        return c
    }

    func toPpm() -> (Int, Int, Int) {
        (clampAndScale(self.r), clampAndScale(self.g), clampAndScale(self.b))
    }
}
