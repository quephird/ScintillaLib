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

    // All three components are expected to lie in the range [0, 1] in both color spaces
    func makeColor(_ component1: Double, _ component2: Double, _ component3: Double) -> Color {
        switch self {
        case .rgb:
            return Color(component1, component2, component3)
        case .hsl:
            // Implementation based on this article, https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB
            let c = component2*(1.0 - abs(2.0*component3 - 1.0))
            let m = component3 - 0.5*c
            let H = component1*6.0
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
            } else if H <= 6 {
                (r, g, b) = (c, 0.0, x)
            }

            return Color(r+m, g+m, b+m)
        }
    }
}

public struct Color {
    var r: Double
    var g: Double
    var b: Double

    public static let white = Color(1.0, 1.0, 1.0)
    public static let black = Color(0.0, 0.0, 0.0)

    // All three components are expected to lie in the range [0, 1]
    public init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    // All three components are expected to lie in the range [0, 1]
    @_spi(Testing) public static func fromHsl(_ h: Double, _ s: Double, _ l: Double) -> Self {
        return ColorSpace.hsl.makeColor(h, s, l)
    }

    @_spi(Testing) public func add(_ other: Self) -> Self {
        Color(self.r+other.r, self.g+other.g, self.b+other.b)
    }

    @_spi(Testing) public func subtract(_ other: Self) -> Self {
        Color(self.r-other.r, self.g-other.g, self.b-other.b)
    }

    @_spi(Testing) public func multiplyScalar(_ scalar: Double) -> Self {
        Color(self.r*scalar, self.g*scalar, self.b*scalar)
    }

    @_spi(Testing) public func divideScalar(_ scalar: Double) -> Self {
        return self.multiplyScalar(1.0/scalar)
    }

    @_spi(Testing) public func hadamard(_ other: Self) -> Self {
        Color(self.r*other.r, self.g*other.g, self.b*other.b)
    }

    @_spi(Testing) public func isAlmostEqual(_ to: Self) -> Bool {
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

    func toBytes() -> [UInt8] {
        [UInt8(clampAndScale(self.r)),
         UInt8(clampAndScale(self.g)),
         UInt8(clampAndScale(self.b))]
    }
}
