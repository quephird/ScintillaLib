//
//  ParametricSurface.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

public typealias ParametricFunction = (Double, Double) -> Double

// TODO: Think about separate values for subdividing u and v
// TODO: Think about having the user pass values in for them
let UV_SUBDIVISIONS = 20

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
        let deltaU = (uEnd - uStart)/Double(UV_SUBDIVISIONS)
        let deltaV = (vEnd - vStart)/Double(UV_SUBDIVISIONS)

        var tuvs: [(Double, Double, Double)] = []
        for i in 0..<UV_SUBDIVISIONS {
            for j in 0..<UV_SUBDIVISIONS {
                let uv1 = points[i, j]
                let uv2 = points[i+1, j]
                let uv3 = points[i+1, j+1]
                let uv4 = points[i, j+1]

                for (p1, p2, p3) in [(uv1, uv2, uv3), (uv2, uv3, uv4), (uv3, uv4, uv1), (uv4, uv1, uv2)] {
                    if let t = checkTriangle(localRay, p1, p2, p3) {
                        // For now return the t for the first triangle hit
                        if tuvs.isEmpty {
                            tuvs.append((t, uStart + Double(i)*deltaU, vStart + Double(j)*deltaV))
                        } else if !tuvs.contains(where: { (existingT, _, _) in
                            return t.isAlmostEqual(existingT)
                        }) {
                            tuvs.append((t, uStart + Double(i)*deltaU, vStart + Double(j)*deltaV))
                        }
                    }
                }
            }
        }

        return tuvs.map { (t, u, v) in
            Intersection(t, .value(u, v), self)
        }
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

    func checkUVRectangle(_ us: (Double, Double), _ vs: (Double, Double), _ localRay: Ray) -> Double? {
        let uv1 = Point(fx(us.0, vs.0), fy(us.0, vs.0), fz(us.0, vs.0))
        let uv2 = Point(fx(us.1, vs.0), fy(us.1, vs.0), fz(us.1, vs.0))
        let uv3 = Point(fx(us.1, vs.1), fy(us.1, vs.1), fz(us.1, vs.1))
        let uv4 = Point(fx(us.0, vs.1), fy(us.0, vs.1), fz(us.0, vs.1))

        // We need to check all four possible triangles because the xyz-points
        // corresponding with the four combinations of uv-values don't necessarily
        // form a convex quadrilateral nor all exist within the same plane.
        for (p1, p2, p3) in [(uv1, uv2, uv3), (uv2, uv3, uv4), (uv3, uv4, uv1), (uv4, uv1, uv2)] {
            if let t = checkTriangle(localRay, p1, p2, p3) {
                // For now return the t for the first triangle hit
                return t
            }
        }

        return nil
    }
}

// This function checks to see if the ray intersects the triangle
// formed by the points p1, p2, and p3 and if it does returns the
// value of t for the ray, else returns nil
func checkTriangle(_ localRay: Ray, _ p1: Point, _ p2: Point, _ p3: Point) -> Double? {
    // Form two sides of the triangle...
    let v1 = p2.subtract(p1)
    let v2 = p3.subtract(p1)

    // ... and test to see if their normal is perpendicular to the ray
    let normal = v1.cross(v2)
    let angle = normal.dot(localRay.direction)
    if abs(angle) < EPSILON {
        // If we got here, then the ray is parallel to the triangle's plane
        return nil
    }

    // Calculate the value of t where the ray intersects the plane formed by the two sides
    let t = (p1.subtract(localRay.origin).dot(normal))/angle
    let point = localRay.position(t)

    // Now check to see if the point lies within the triangle by
    // inspecting where the point is with respect to each pair of
    // adjacent sides...
    for (pLeft, pCorner, pRight) in [(p1, p2, p3), (p2, p3, p1), (p3, p1, p2)] {
        let vLeft = pLeft.subtract(pCorner)
        let vRight = pRight.subtract(pCorner)
        let pointToCorner = point.subtract(pCorner)
        let projectionToLeft = pointToCorner.project(vLeft)
        let projectionToRight = pointToCorner.project(vRight)

        if projectionToLeft.magnitude() > vLeft.magnitude() ||
            projectionToRight.magnitude() > vRight.magnitude()
        {
            // We have a miss, return immediately...
            return nil
        }
    }

    return t
}
