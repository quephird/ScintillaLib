//
//  Color.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/19/21.
//

import Foundation

public enum ColorSpace {
    case rgb
    case hsl
}

public struct Color {
    var r: Double
    var g: Double
    var b: Double

    public static let white = Color(1.0, 1.0, 1.0)
    public static let black = Color(0.0, 0.0, 0.0)

    public init(_ component1: Double, _ component2: Double, _ component3: Double, _ colorSpace: ColorSpace = .rgb) {
        switch colorSpace {
        case .rgb:
            self.r = component1
            self.g = component2
            self.b = component3
        case .hsl:
            let (r, g, b) = Self.toRgb(component1, component2, component3)
            self.r = r
            self.g = g
            self.b = b
        }
    }

    static func toRgb(_ h: Double, _ s: Double, _ l: Double) -> (Double, Double, Double) {
        let c = s*(1.0 - abs(2.0*l - 1.0))
        let m = l - 0.5*c
        let H = h*6.0
        let x = c*(1.0 - abs(H.truncatingRemainder(dividingBy: 2.0) - 1.0))

        var r = 0.0
        var g = 0.0
        var b = 0.0

        if H < 1 {
            (r, g, b) = (c, x, 0.0)
        } else if H < 2 {
            (r, g, b) = (x, c, 0.0)
        } else if H < 3 {
            (r, g, b) = (0.0, c, x)
        } else if H < 4 {
            (r, g, b) = (0.0, x, c)
        } else if H < 5 {
            (r, g, b) = (x, 0.0, c)
        } else if H < 6 {
            (r, g, b) = (c, 0.0, x)
        }

        return (r+m, g+m, b+m)
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

    func divideScalar(_ scalar: Double) -> Self {
        return self.multiplyScalar(1.0/scalar)
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
