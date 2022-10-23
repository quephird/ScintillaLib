//
//  Tuple.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/19/21.
//

import Foundation

public struct Tuple4 {
    var data: (Double, Double, Double, Double)

    public init(_ x: Double, _ y: Double, _ z: Double, _ w: Double) {
        self.data = (x, y, z, w)
    }

    var x: Double {
        self.data.0
    }

    var y: Double {
        self.data.1
    }

    var z: Double {
        self.data.2
    }

    subscript(_ index: Int) -> Double {
        get {
            switch index {
            case 0: return self.data.0
            case 1: return self.data.1
            case 2: return self.data.2
            case 3: return self.data.3
            default: fatalError()
            }
        }
        set(newValue) {
            switch index {
            case 0: self.data.0 = newValue
            case 1: self.data.1 = newValue
            case 2: self.data.2 = newValue
            case 3: self.data.3 = newValue
            default: fatalError()
            }
        }
    }

    func add(_ other: Self) -> Self {
        Tuple4(
            self[0]+other[0],
            self[1]+other[1],
            self[2]+other[2],
            self[3]+other[3]
        )
    }

    func subtract(_ other: Self) -> Self {
        Tuple4(
            self[0]-other[0],
            self[1]-other[1],
            self[2]-other[2],
            self[3]-other[3]
        )
    }

    func negate() -> Self {
        Tuple4(-self[0], -self[1], -self[2], -self[3])
    }

    func multiplyScalar(_ scalar: Double) -> Self {
        Tuple4(
            scalar*self[0],
            scalar*self[1],
            scalar*self[2],
            scalar*self[3]
        )
    }

    func divideScalar(_ scalar: Double) -> Self {
        Tuple4(
            self[0]/scalar,
            self[1]/scalar,
            self[2]/scalar,
            self[3]/scalar
        )
    }

    func magnitude() -> Double {
        (self[0]*self[0] +
            self[1]*self[1] +
            self[2]*self[2] +
            self[3]*self[3]).squareRoot()
    }

    func normalize() -> Self {
        self.divideScalar(self.magnitude())
    }

    func dot(_ other: Self) -> Double {
        self[0]*other[0] +
            self[1]*other[1] +
            self[2]*other[2] +
            self[3]*other[3]
    }

    func cross(_ other: Self) -> Self {
        vector(
            self[1] * other[2] - self[2] * other[1],
            self[2] * other[0] - self[0] * other[2],
            self[0] * other[1] - self[1] * other[0]
        )
    }

    func reflect(_ normal: Tuple4) -> Tuple4 {
        return self.subtract(normal.multiplyScalar(2 * self.dot(normal)))
    }

    func isAlmostEqual(_ to: Self) -> Bool {
        self[0].isAlmostEqual(to[0]) &&
            self[1].isAlmostEqual(to[1]) &&
            self[2].isAlmostEqual(to[2]) &&
            self[3].isAlmostEqual(to[3])
    }

    func project(_ onto: Self) -> Self {
        let sDotO = self.dot(onto)
        return onto
            .multiplyScalar(sDotO)
            .divideScalar(onto.magnitude()*onto.magnitude())
    }
}

public func point(_ x: Double, _ y: Double, _ z: Double) -> Tuple4 {
    Tuple4(x, y, z, 1.0)
}

public func vector(_ x: Double, _ y: Double, _ z: Double) -> Tuple4 {
    Tuple4(x, y, z, 0.0)
}
