//
//  Tuple.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/19/21.
//

import Foundation

public protocol Tuple4 {
    var data: (Double, Double, Double, Double) { get set }
}

extension Tuple4 {
    var x: Double {
        self.data.0
    }

    var y: Double {
        self.data.1
    }

    var z: Double {
        self.data.2
    }

    var w: Double {
        self.data.3
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

    func isAlmostEqual(_ to: Self) -> Bool {
        self[0].isAlmostEqual(to[0]) &&
            self[1].isAlmostEqual(to[1]) &&
            self[2].isAlmostEqual(to[2]) &&
            self[3].isAlmostEqual(to[3])
    }
}

public struct Point: Tuple4 {
    public var data: (Double, Double, Double, Double)

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.data = (x, y, z, 1.0)
    }

    func add(_ other: Vector) -> Point {
        Point(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )
    }

    func subtract(_ other: Vector) -> Point {
        Point(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z
        )
    }

    func subtract(_ other: Self) -> Vector {
        Vector(
            self.x - other.x,
            self.x - other.y,
            self.x - other.z
        )
    }
}

public struct Vector: Tuple4 {
    public var data: (Double, Double, Double, Double)

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.data = (x, y, z, 0.0)
    }

    func add(_ other: Vector) -> Vector {
        Vector(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )
    }

    func add(_ other: Point) -> Point {
        Point(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )
    }

    func negate() -> Self {
        Vector(-self.x, -self.y, -self.z)
    }

    func subtract(_ other: Self) -> Self {
        self.add(other.negate())
    }

    func multiplyScalar(_ scalar: Double) -> Self {
        Vector(
            scalar*self.x,
            scalar*self.y,
            scalar*self.z
        )
    }

    func divideScalar(_ scalar: Double) -> Self {
        self.multiplyScalar(1/scalar)
    }

    func magnitude() -> Double {
        (self.x*self.x + self.y*self.y + self.z*self.z).squareRoot()
    }

    func normalize() -> Self {
        self.divideScalar(self.magnitude())
    }

    func dot(_ other: Self) -> Double {
        self.x*other.x + self.y*other.y + self.z*other.z
    }

    func cross(_ other: Self) -> Self {
        Vector(
            self.x*other.z - self.z*other.y,
            self.z*other.x - self.x*other.z,
            self.x*other.y - self.y*other.x
        )
    }

    func reflect(_ normal: Vector) -> Vector {
        self.subtract(normal.multiplyScalar(2 * self.dot(normal)))
    }

    func project(_ onto: Self) -> Self {
        let sDotO = self.dot(onto)
        return onto
            .multiplyScalar(sDotO)
            .divideScalar(onto.magnitude()*onto.magnitude())
    }

    func angle(_ with: Self) -> Double {
        return acos(self.dot(with)/self.magnitude()/with.magnitude())
    }
}
