//
//  ParametricSurface.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

import Darwin

public typealias ParametricFunction = (Double, Double) -> Double

// TODO: Think about separate values for subdividing u and v
// TODO: Think about having the user pass values in for them
let UV_SUBDIVISIONS = 10
let MAX_RECURSIONS = 30

@_spi(Testing) public enum UV {
    case none
    case value(Double, Double)
}

struct PointSet {
    private var _storage: [Point]
    private(set) var columns: Int

    private var rows: Int { _storage.count / columns }

    private func indexFor(column: Int, row: Int) -> Int {
        column * rows + row
    }

    static private func coordinates(for index: Int, withRows rows: Int) -> Index {
        Index(column: index / rows, row: index % rows)
    }

    init(columns: Int, rows: Int, makeElement: (Int, Int) -> Point) {
        self.columns = columns

        _storage = Array(unsafeUninitializedCapacity: rows * columns) { buffer, initializedCount in
            // `makeElement` will be captured by the escaping closure passed to `map`, but the result
            // of `map` will be used and discarded before the initializer returns, so it's safe to
            // use `withoutActuallyEscaping`.
            withoutActuallyEscaping(makeElement) { makeElement in
                _ = buffer.initialize(
                    from: buffer.indices.lazy.map { i in
                        let pointIndex = Self.coordinates(for: i, withRows: rows)
                        return makeElement(pointIndex.column, pointIndex.row)
                    }
                )
            }
            initializedCount = buffer.count
        }
    }

    subscript(_ column: Int, _ row: Int) -> Point {
        get {
            _storage[indexFor(column: column, row: row)]
        }
        _modify {
            yield &_storage[indexFor(column: column, row: row)]
        }
    }
}

extension PointSet: MutableCollection, RandomAccessCollection {
    var startIndex: Index {
        Index(column: 0, row: 0)
    }

    var endIndex: Index {
        Index(column: columns + 1, row: 0)
    }

    func index(before i: Index) -> Index {
        index(i, offsetBy: -1)
    }

    func index(after i: Index) -> Index {
        index(i, offsetBy: 1)
    }

    struct Index: Comparable, Hashable {
        static func < (lhs: PointSet.Index, rhs: PointSet.Index) -> Bool {
            (lhs.column, lhs.row) < (rhs.column, rhs.row)
        }

        var column: Int
        var row: Int
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        let storageIndex = indexFor(column: i.column, row: i.row) + distance
        return Self.coordinates(for: storageIndex, withRows: rows)
    }

    func distance(from start: Index, to end: Index) -> Int {
        let startStorageIndex = indexFor(column: start.column, row: start.row)
        let endStorageIndex = indexFor(column: end.column, row: end.row)
        return endStorageIndex - startStorageIndex
    }

    subscript(position: Index) -> Point {
        get { self[position.column, position.row] }
        _modify { yield &self[position.column, position.row] }
    }
}

public class ParametricSurface: Shape {
    var fx: ParametricFunction
    var fy: ParametricFunction
    var fz: ParametricFunction
    var boundingShape: Shape
    var uRange: (Double, Double)
    var vRange: (Double, Double)
    var points: PointSet

    public convenience init(_ bottomFrontLeft: Point3D,
                            _ topBackRight: Point3D,
                            _ uRange: (Double, Double),
                            _ vRange: (Double, Double),
                            _ fx: @escaping ParametricFunction,
                            _ fy: @escaping ParametricFunction,
                            _ fz: @escaping ParametricFunction) {
        let (xMin, yMin, zMin) = bottomFrontLeft
        let (xMax, yMax, zMax) = topBackRight
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yMax-yMin)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yMax+yMin)/2, (zMax+zMin)/2)
        let boundingShape = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        self.init(boundingShape, uRange, vRange, fx, fy, fz)
    }

    public init(_ boundingShape: Shape,
                _ uRange: (Double, Double),
                _ vRange: (Double, Double),
                _ fx: @escaping ParametricFunction,
                _ fy: @escaping ParametricFunction,
                _ fz: @escaping ParametricFunction) {
        self.boundingShape = boundingShape
        self.uRange = uRange
        self.vRange = vRange
        self.fx = fx
        self.fy = fy
        self.fz = fz

        self.points = PointSet(columns: UV_SUBDIVISIONS + 1, rows: UV_SUBDIVISIONS + 1) { i, j in
            let u = uRange.0 + (uRange.1 - uRange.0)*Double(i)/Double(UV_SUBDIVISIONS)
            let v = vRange.0 + (vRange.1 - vRange.0)*Double(j)/Double(UV_SUBDIVISIONS)
            return Point(fx(u, v), fy(u, v), fz(u, v))
        }
    }

    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // First we check to see if the ray intersects the bounding shape;
        // note that we need a pair of hits in order to construct a range
        // of values for t below...
        let boundingBoxIntersections = self.boundingShape.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        let (uStart, uEnd) = uRange
        let (vStart, vEnd) = vRange
        var xCurr = [uStart, vStart, 0.0]
        var iterations = 0

        let j = makeJacobian(fx, fy, fz, localRay)
        let f = makeF(fx, fy, fz, localRay)
        while iterations < MAX_RECURSIONS {
            let fPrev = f(xCurr[0], xCurr[1], xCurr[2])
            let jPrev = j(xCurr[0], xCurr[1], xCurr[2])
            let system = makeSystemOfThreeEquations(jPrev, fPrev)

            if let yPrev = solve(system) {
                xCurr = [
                    xCurr[0] + yPrev[0],
                    xCurr[1] + yPrev[1],
                    xCurr[2] + yPrev[2],
                ]
                if norm(yPrev) < EPSILON {
                    return [Intersection(xCurr[2], .value(xCurr[0], xCurr[1]), self)]
                } else {
                    iterations += 1
                }
            } else {
                return []
            }

        }

        return []
    }

    @_spi(Testing) public override func localNormal(_ localPoint: Point, _ uv: UV) -> Vector {
        switch uv {
        case .value(let u, let v):
            let gradFxu = (fx(u + DELTA, v) - fx(u, v))/DELTA
            let gradFxv = (fx(u, v + DELTA) - fx(u, v))/DELTA
            let gradFyu = (fy(u + DELTA, v) - fy(u, v))/DELTA
            let gradFyv = (fy(u, v + DELTA) - fy(u, v))/DELTA
            let gradFzu = (fz(u + DELTA, v) - fz(u, v))/DELTA
            let gradFzv = (fz(u, v + DELTA) - fz(u, v))/DELTA

            let gradFu = Vector(gradFxu, gradFyu, gradFzu)
            let gradFv = Vector(gradFxv, gradFyv, gradFzv)

            return gradFu.cross(gradFv).normalize()
        default:
            fatalError("Whoops... you need to pass in a uv pair!")
        }
    }
}

public typealias FunctionOfThreeVariables = (Double, Double, Double) -> Double
public typealias Jacobian = (Double, Double, Double) -> [[Double]]
public typealias Matrix = [[Double]]

func makeJacobian(_ fx: @escaping ParametricFunction,
                  _ fy: @escaping ParametricFunction,
                  _ fz: @escaping ParametricFunction,
                  _ localRay: Ray) -> Jacobian {
    // These are the three components of the ray equation:
    //
    //     r⃑ = o + td⃑
    func ftx(_ t: Double) -> Double {
        localRay.origin.x + t*localRay.direction.x
    }
    func fty(_ t: Double) -> Double {
        localRay.origin.y + t*localRay.direction.y
    }
    func ftz(_ t: Double) -> Double {
        localRay.origin.z + t*localRay.direction.z
    }

    // The system of equations are:
    //
    //    fx(u, v) - ftx(t) = 0
    //    fy(u, v) - fty(t) = 0
    //    fz(u, v) - ftz(t) = 0
    func f1(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fx(u, v) - ftx(t)
    }
    func f2(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fy(u, v) - fty(t)
    }
    func f3(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fz(u, v) - ftz(t)
    }

    return makeJacobian(f1, f2, f3)
}

func makeJacobian(_ f1: @escaping FunctionOfThreeVariables,
                  _ f2: @escaping FunctionOfThreeVariables,
                  _ f3: @escaping FunctionOfThreeVariables) -> Jacobian {
    // Set up all the gradients
    func gradF1u(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f1(u + DELTA, v, t) - f1(u, v, t))/DELTA
    }
    func gradF1v(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f1(u, v + DELTA, t) - f1(u, v, t))/DELTA
    }
    func gradF1t(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f1(u, v, t + DELTA) - f1(u, v, t))/DELTA
    }
    func gradF2u(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f2(u + DELTA, v, t) - f2(u, v, t))/DELTA
    }
    func gradF2v(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f2(u, v + DELTA, t) - f2(u, v, t))/DELTA
    }
    func gradF2t(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f2(u, v, t + DELTA) - f2(u, v, t))/DELTA
    }
    func gradF3u(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f3(u + DELTA, v, t) - f3(u, v, t))/DELTA
    }
    func gradF3v(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f3(u, v + DELTA, t) - f3(u, v, t))/DELTA
    }
    func gradF3t(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return (f3(u, v, t + DELTA) - f3(u, v, t))/DELTA
    }

    func jacobian(_ u: Double, _ v: Double, _ t: Double) -> [[Double]] {
    [
        [gradF1u(u, v, t), gradF1v(u, v, t), gradF1t(u, v, t)],
        [gradF2u(u, v, t), gradF2v(u, v, t), gradF2t(u, v, t)],
        [gradF3u(u, v, t), gradF3v(u, v, t), gradF3t(u, v, t)],
    ]
    }

    return jacobian
}

public typealias F = (Double, Double, Double) -> [Double]

func makeF(_ fx: @escaping ParametricFunction,
           _ fy: @escaping ParametricFunction,
           _ fz: @escaping ParametricFunction,
           _ localRay: Ray) -> F {
    // These are the three components of the ray equation:
    //
    //     r⃑ = o + td⃑
    func ftx(_ t: Double) -> Double {
        localRay.origin.x + t*localRay.direction.x
    }
    func fty(_ t: Double) -> Double {
        localRay.origin.y + t*localRay.direction.y
    }
    func ftz(_ t: Double) -> Double {
        localRay.origin.z + t*localRay.direction.z
    }

    // The system of equations are:
    //
    //    fx(u, v) - ftx(t) = 0
    //    fy(u, v) - fty(t) = 0
    //    fz(u, v) - ftz(t) = 0
    func f1(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fx(u, v) - ftx(t)
    }
    func f2(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fy(u, v) - fty(t)
    }
    func f3(_ u: Double, _ v: Double, _ t: Double) -> Double {
        return fz(u, v) - ftz(t)
    }

    return makeF(f1, f2, f3)
}

func makeF(_ f1: @escaping FunctionOfThreeVariables,
           _ f2: @escaping FunctionOfThreeVariables,
           _ f3: @escaping FunctionOfThreeVariables) -> F {
    func F(_ u: Double, _ v: Double, _ t: Double) -> [Double] {
        [f1(u, v, t), f2(u, v, t), f3(u, v, t)]
    }

    return F
}

func makeSystemOfThreeEquations(_ jacobianValues: [[Double]], _ fValues: [Double]) -> [[Double]] {
    var matrix: [[Double]] = []

    for j in 0..<jacobianValues.count {
        var newRow = jacobianValues[j]
        newRow.append(-fValues[j])
        matrix.append(newRow)
    }

    return matrix
}

func norm(_ vector: [Double]) -> Double {
    var temp = 0.0
    for component in vector {
        temp += component*component
    }

    return sqrt(temp)
}
