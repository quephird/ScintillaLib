//
// Created by Danielle Kefford on 11/21/21.
//

import Foundation

public struct Matrix2 {
    var data: (
        Double, Double,
        Double, Double
        )

    @_spi(Testing) public init(
        _ x0: Double, _ y0: Double,
        _ x1: Double, _ y1: Double) {
        self.data = (x0, y0, x1, y1)
    }

    subscript(_ i: Int, _ j: Int) -> Double {
        get {
            let index = j*2+i
            switch index {
            case 0: return self.data.0
            case 1: return self.data.1
            case 2: return self.data.2
            case 3: return self.data.3
            default: fatalError()
            }
        }
        set(newValue) {
            let index = j*2+i
            switch index {
            case 0: self.data.0 = newValue
            case 1: self.data.1 = newValue
            case 2: self.data.2 = newValue
            case 3: self.data.3 = newValue
            default: fatalError()
            }
        }
    }

    @_spi(Testing) public func determinant() -> Double {
        self[0, 0]*self[1, 1] - self[0, 1]*self[1, 0]
    }

    @_spi(Testing) public func isAlmostEqual(_ other: Matrix2) -> Bool {
        for j in 0...1 {
            for i in 0...1 {
                if !self[i, j].isAlmostEqual(other[i, j]) {
                    return false
                }
            }
        }
        return true
    }
}

public struct Matrix3 {
    var data: (
        Double, Double, Double,
        Double, Double, Double,
        Double, Double, Double
        )

    @_spi(Testing) public init(
        _ x0: Double, _ y0: Double, _ z0: Double,
        _ x1: Double, _ y1: Double, _ z1: Double,
        _ x2: Double, _ y2: Double, _ z2: Double) {
        self.data = (x0, y0, z0, x1, y1, z1, x2, y2, z2)
    }

    subscript(_ i: Int, _ j: Int) -> Double {
        get {
            let index = j*3+i
            switch index {
            case 0: return self.data.0
            case 1: return self.data.1
            case 2: return self.data.2
            case 3: return self.data.3
            case 4: return self.data.4
            case 5: return self.data.5
            case 6: return self.data.6
            case 7: return self.data.7
            case 8: return self.data.8
            default: fatalError()
            }
        }
        set(newValue) {
            let index = j*3+i
            switch index {
            case 0: self.data.0 = newValue
            case 1: self.data.1 = newValue
            case 2: self.data.2 = newValue
            case 3: self.data.3 = newValue
            case 4: self.data.4 = newValue
            case 5: self.data.5 = newValue
            case 6: self.data.6 = newValue
            case 7: self.data.7 = newValue
            case 8: self.data.8 = newValue
            default: fatalError()
            }
        }
    }

    @_spi(Testing) public func submatrix(_ row: Int, _ column: Int) -> Matrix2 {
        var m = Matrix2(
            0, 0,
            0, 0
        )
        var targetRow = 0
        for sourceRow in 0...2 {
            if sourceRow == row {
                continue
            }
            var targetColumn = 0
            for sourceColumn in 0...2 {
                if sourceColumn == column {
                    continue
                }
                m[targetColumn, targetRow] = self[sourceColumn, sourceRow]
                targetColumn += 1
            }
            targetRow += 1
        }

        return m
    }

    @_spi(Testing) public func minor(_ row: Int, _ column: Int) -> Double {
        self.submatrix(row, column).determinant()
    }

    @_spi(Testing) public func cofactor(_ row: Int, _ column: Int) -> Double {
        var coefficient = 1.0
        if (row + column)%2 != 0 {
            coefficient = -1.0
        }
        let minor = self.minor(row, column)
        return coefficient*minor
    }

    @_spi(Testing) public func determinant() -> Double {
        var d = 0.0
        for i in 0...2 {
            d += self.cofactor(0, i)*self[i, 0]
        }
        return d
    }

    @_spi(Testing) public func isAlmostEqual(_ other: Matrix3) -> Bool {
        for j in 0...2 {
            for i in 0...2 {
                if !self[i, j].isAlmostEqual(other[i, j]) {
                    return false
                }
            }
        }
        return true
    }
}

public struct Matrix4: Equatable {
    var data: (
        Double, Double, Double, Double,
        Double, Double, Double, Double,
        Double, Double, Double, Double,
        Double, Double, Double, Double
        )

    public static let identity = Matrix4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )

    @_spi(Testing) public init(
        _ x0: Double, _ y0: Double, _ z0: Double, _ w0: Double,
        _ x1: Double, _ y1: Double, _ z1: Double, _ w1: Double,
        _ x2: Double, _ y2: Double, _ z2: Double, _ w2: Double,
        _ x3: Double, _ y3: Double, _ z3: Double, _ w3: Double) {
        self.data = (
            x0, y0, z0, w0,
            x1, y1, z1, w1,
            x2, y2, z2, w2,
            x3, y3, z3, w3
        )
    }

    public static func == (lhs: Matrix4, rhs: Matrix4) -> Bool {
        return (lhs.data.0 == rhs.data.0) &&
               (lhs.data.1 == rhs.data.1) &&
               (lhs.data.2 == rhs.data.2) &&
               (lhs.data.3 == rhs.data.3) &&
               (lhs.data.4 == rhs.data.4) &&
               (lhs.data.5 == rhs.data.5) &&
               (lhs.data.6 == rhs.data.6) &&
               (lhs.data.7 == rhs.data.7) &&
               (lhs.data.8 == rhs.data.8) &&
               (lhs.data.9 == rhs.data.9) &&
               (lhs.data.10 == rhs.data.10) &&
               (lhs.data.11 == rhs.data.11) &&
               (lhs.data.12 == rhs.data.12) &&
               (lhs.data.13 == rhs.data.13) &&
               (lhs.data.14 == rhs.data.14) &&
               (lhs.data.15 == rhs.data.15)
    }

    public static func translation(_ x: Double, _ y: Double, _ z: Double) -> Self {
        return Matrix4(
            1, 0, 0, x,
            0, 1, 0, y,
            0, 0, 1, z,
            0, 0, 0, 1
        )
    }

    public static func scaling(_ x: Double, _ y: Double, _ z: Double) -> Self {
        return Matrix4(
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        )
    }

    public static func rotationX(_ t: Double) -> Self {
        return Matrix4(
            1, 0,      0,       0,
            0, cos(t), -sin(t), 0,
            0, sin(t), cos(t),  0,
            0, 0,      0,       1
        )
    }

    public static func rotationY(_ t: Double) -> Self {
        return Matrix4(
            cos(t),  0, sin(t), 0,
            0,       1, 0,      0,
            -sin(t), 0, cos(t), 0,
            0, 0,      0,       1
        )
    }

    public static func rotationZ(_ t: Double) -> Self {
        return Matrix4(
            cos(t), -sin(t), 0, 0,
            sin(t), cos(t),  0, 0,
            0,      0,       1, 0,
            0,      0,       0, 1
        )
    }

    public static func shearing(_ xy: Double, _ xz: Double, _ yx: Double, _ yz: Double, _ zx: Double, _ zy: Double) -> Self {
        return Matrix4(
            1,  xy, xz, 0,
            yx, 1,  yz, 0,
            zx, zy, 1,  0,
            0,  0,  0,  1
        )
    }

    public static func view(_ from: Point, _ to: Point, _ up: Vector) -> Matrix4 {
        let forward = to.subtract(from).normalize()
        let upNormalized = up.normalize()
        let left = forward.cross(upNormalized)
        let upTrue = left.cross(forward)
        let orientation = Matrix4(
            left[0],     left[1],     left[2],     0,
            upTrue[0],   upTrue[1],   upTrue[2],   0,
            -forward[0], -forward[1], -forward[2], 0,
            0,           0,           0,           1
        )
        let transform = translation(-from[0], -from[1], -from[2])
        return orientation.multiply(transform)
    }

    subscript(_ i: Int, _ j: Int) -> Double {
        get {
            let index = j*4+i
            switch index {
            case 0: return self.data.0
            case 1: return self.data.1
            case 2: return self.data.2
            case 3: return self.data.3
            case 4: return self.data.4
            case 5: return self.data.5
            case 6: return self.data.6
            case 7: return self.data.7
            case 8: return self.data.8
            case 9: return self.data.9
            case 10: return self.data.10
            case 11: return self.data.11
            case 12: return self.data.12
            case 13: return self.data.13
            case 14: return self.data.14
            case 15: return self.data.15
            default: fatalError()
            }
        }
        set(newValue) {
            let index = j*4+i
            switch index {
            case 0: self.data.0 = newValue
            case 1: self.data.1 = newValue
            case 2: self.data.2 = newValue
            case 3: self.data.3 = newValue
            case 4: self.data.4 = newValue
            case 5: self.data.5 = newValue
            case 6: self.data.6 = newValue
            case 7: self.data.7 = newValue
            case 8: self.data.8 = newValue
            case 9: self.data.9 = newValue
            case 10: self.data.10 = newValue
            case 11: self.data.11 = newValue
            case 12: self.data.12 = newValue
            case 13: self.data.13 = newValue
            case 14: self.data.14 = newValue
            case 15: self.data.15 = newValue
            default: fatalError()
            }
        }
    }

    @_spi(Testing) public func isAlmostEqual(_ other: Matrix4) -> Bool {
        for j in 0...3 {
            for i in 0...3 {
                if !self[i, j].isAlmostEqual(other[i, j]) {
                    return false
                }
            }
        }
        return true
    }

    @_spi(Testing) public func multiply(_ other: Matrix4) -> Matrix4 {
        var m = Matrix4(
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
        )
        for r in 0...3 {
            for c in 0...3 {
                m[c, r] = self[0, r]*other[c, 0] +
                          self[1, r]*other[c, 1] +
                          self[2, r]*other[c, 2] +
                          self[3, r]*other[c, 3]
            }
        }
        return m
    }

    @_spi(Testing) public func multiply(_ vector: Vector) -> Vector {
        var v = Vector(0, 0, 0)
        for r in 0...3 {
            v[r] = self[0, r]*vector.x + self[1, r]*vector.y + self[2, r]*vector.z
        }
        return v
    }

    @_spi(Testing) public func multiply(_ point: Point) -> Point {
        var p = Point(0, 0, 0)
        for r in 0...3 {
            p[r] = self[0, r]*point.x + self[1, r]*point.y + self[2, r]*point.z + self[3, r]
        }
        return p
    }

    @_spi(Testing) public func transpose() -> Matrix4 {
        var m = Matrix4(
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
        )
        for r in 0...3 {
            for c in 0...3 {
                m[c, r] = self[r, c]
            }
        }
        return m
    }

    @_spi(Testing) public func submatrix(_ row: Int, _ column: Int) -> Matrix3 {
        var m = Matrix3(
            0, 0, 0,
            0, 0, 0,
            0, 0, 0
        )
        var targetRow = 0
        for sourceRow in 0...3 {
            if sourceRow == row {
                continue
            }
            var targetColumn = 0
            for sourceColumn in 0...3 {
                if sourceColumn == column {
                    continue
                }
                m[targetColumn, targetRow] = self[sourceColumn, sourceRow]
                targetColumn += 1
            }
            targetRow += 1
        }

        return m
    }

    func minor(_ row: Int, _ column: Int) -> Double {
        self.submatrix(row, column).determinant()
    }

    func cofactor(_ row: Int, _ column: Int) -> Double {
        var coefficient = 1.0
        if (row + column)%2 != 0 {
            coefficient = -1.0
        }
        let minor = self.minor(row, column)
        return coefficient*minor
    }

    @_spi(Testing) public func determinant() -> Double {
        var d = 0.0
        for i in 0...3 {
            d += self.cofactor(0, i)*self[i, 0]
        }
        return d
    }

    @_spi(Testing) public func inverse() -> Matrix4 {
        let d = self.determinant()
        var m = Matrix4(
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0
        )
        for r in 0...3 {
            for c in 0...3 {
                m[r, c] = self.cofactor(r, c)/d
            }
        }
        return m
    }
}
