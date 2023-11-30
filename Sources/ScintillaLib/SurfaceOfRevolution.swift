//
//  SurfaceOfRevolution.swift
//  
//
//  Created by Danielle Kefford on 10/30/22.
//

public typealias Point2D = (Double, Double)

// This shape takes a set of points that lie in the yz-plane,
// generates a piecewise-defined and continuous cubic spline
// function that passes through all of those points, and creates
// an `ImplicitSurface` shape that represents that curve rotated
// about the y-axis. This function, called g(y) below, is then
// incorporated into the one passed to the implicit surface,
// namely, x² + z² - g²(y). The implicit surface shape is then
// subsequently used for all computations for ray intersections
// and normal vectors.
@available(macOS 10.15, *)
public struct SurfaceOfRevolution: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()

    var underlyingImplicitSurface: ImplicitSurface
    var yBottom: Double
    var yTop: Double
    var rBottom: Double
    var rTop: Double
    var isCapped: Bool

    public init(yzPoints: [Point2D]) {
        self.init(yzPoints: yzPoints, isCapped: false)
    }

    public init(yzPoints: [Point2D], isCapped: Bool) {
        let ys = yzPoints.map { point in
            point.0
        }
        let zs = yzPoints.map { point in
            point.1
        }

        // Note that due to the symmetry of rotation, the minimum
        // and maximum values for the x -coordinate are the same as
        // those for the z-coordinate. Also, the multipliers for the
        // min and max x and z values is somewhat arbitrary just to
        // insure that the bounding box isn't too small along those
        // axes and result in clipping.
        let (xMin, yMin, zMin) = (-zs.max()!*2.0, ys.min()!, -zs.max()!*2.0)
        let (xMax, yMax, zMax) = (zs.max()!*2.0, ys.max()!, zs.max()!*2.0)

        // Note that we perform all these computations and make
        // this shape here in the constructor so that it is only
        // done once and then reused in all subsequent computations.
        let matrix = makeCubicSplineMatrix(yzPoints)
        let solution = solve(matrix)!
        let coefficientsList: [CubicPolynomialCoefficients] = stride(from: 0, to: solution.count, by: 4).map {
            let array = Array(solution[$0..<min($0 + 4, solution.count)])
            return (array[0], array[1], array[2], array[3])
        }
        let g = makePiecewiseCubicSplineFunction(yzPoints, coefficientsList)!
        func f(_ x: Double, _ y: Double, _ z: Double) -> Double {
            x*x + z*z - g(y)*g(y)
        }
        let underlyingImplicitSurface = ImplicitSurface(bottomFrontLeft: (xMin, yMin, zMin), topBackRight: (xMax, yMax, zMax), f)

        self.isCapped = isCapped
        self.yBottom = yMin
        self.yTop = yMax
        self.rBottom = zs.first!
        self.rTop = zs.last!
        self.underlyingImplicitSurface = underlyingImplicitSurface
    }

    func localIntersectCaps(_ localRay: Ray) -> [Intersection] {
        var intersections: [Intersection] = []

        for (y, r) in [(yBottom, rBottom), (yTop, rTop)] {
            let t = (y - localRay.origin.y) / localRay.direction.y
            let x = localRay.origin.x + t * localRay.direction.x
            let z = localRay.origin.z + t * localRay.direction.z
            if (x*x + z*z) <= r*r {
                intersections.append(Intersection(t, self))
            }
        }

        return intersections
    }

    @_spi(Testing) public func localIntersect(_ localRay: Ray) -> [Intersection] {
        var intersections: [Intersection] = []

        if isCapped {
            intersections.append(contentsOf: self.localIntersectCaps(localRay))
        }

        // We map over the intersections for the underlying shape
        // so that the ones returned to the caller have a reference
        // to _this_ shape and its material properties. Otherwise,
        // we would send back the wrong shape and the default material,
        // which is obviously undesirable.
        let wallIntersections = self.underlyingImplicitSurface
            .localIntersect(localRay)
            .map { intersection in
                return Intersection(intersection.t, self)
            }

        intersections.append(contentsOf: wallIntersections)

        return intersections
    }

    @_spi(Testing) public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        if isCapped {
            let (x, y, z) = (localPoint.x, localPoint.y, localPoint.z)
            if abs(y - self.yBottom) < DELTA && (x*x + z*z) <= rBottom*rBottom {
                return Vector(0.0, -1.0, 0.0)
            } else if abs(y - self.yTop) < DELTA && (x*x + z*z) <= rTop*rTop {
                return Vector(0.0, 1.0, 0.0)
            }
        }

        return self.underlyingImplicitSurface.localNormal(localPoint)
    }
}

// This function takes an n ⨯ n+1 augmented matrix representing
// a system of n equations with n unknowns, solves them using
// Gaussian elimination, and returns the solution as an array
// of values of length n. Implementation modeled on this article:
//
// https://en.wikipedia.org/wiki/Gaussian_elimination
@_spi(Testing) public func solve(_ matrix: [[Double]]) -> [Double]? {
    precondition(
        matrix.allSatisfy { row in
            row.count == matrix.count + 1
        }, "Matrix is malformed!")

    var copy = matrix

    // First start at the second row, and put the matrix
    // in row echelon form, which means that we want the values
    // of all cells below the diagonal to be 0, like this:
    //
    // ⎡  2   1  -1   8⎤
    // ⎢ -3  -1   2 -11⎥
    // ⎣ -2   1   2  -3⎦
    for i in 1..<copy.count {
        // Before we begin processing this row, we need to make sure
        // the current pivot value is not zero. If it is, then
        // we need to swap that row with one that has a non-zero value;
        // if it does not, then this matrix represents a system of
        // equations that is not solvable.
        if copy[i-1][i-1] == 0 {
            if let swapIndex = (i..<copy.count).first(where: { index in
                copy[index][i-1] != 0.0
            }) {
                copy.swapAt(i-1, swapIndex)
            } else {
                return nil
            }
        }
        for j in i..<copy.count {
            let m = -copy[j][i-1]/copy[i-1][i-1]
            for k in 0..<copy[j].count {
                copy[j][k] = copy[j][k] + m*copy[i-1][k]
            }
        }
    }

    // Now that we have the matrix in row echelon form,
    // we need to see if any cells along the diagonal are zero.
    // If one exists, then there is no unique solution,
    // and we should bail
    for i in 1..<copy.count {
        if copy[i][i] == 0 {
            return nil
        }
    }

    // Next, we work back upwards starting from the next to
    // last row and turn all the cell values _above_ the diagonal
    // to 0, like this
    //
    // ⎡  2   0   0   4⎤
    // ⎢  0 0.5   0 1.5⎥
    // ⎣  0   0  -1   1⎦
    for i in (1..<copy.count).reversed() {
        for j in (1...i).reversed() {
            let m = -copy[j-1][i]/copy[i][i]
            for k in 0..<copy[j].count {
                copy[j-1][k] = copy[j-1][k] + m*copy[i][k]
            }
        }
    }

    // ... finally "normalize" all the rows such that all the
    // vales along the diagonal are 1, otherwise known as
    // reduced row echelon form, like this:
    //
    // ⎡  1   0   0   2⎤
    // ⎢  0   1   0   3⎥
    // ⎣  0   0   1  -1⎦
    for i in 0..<copy.count {
        let m = 1.0/copy[i][i]
        for j in 0..<copy[i].count {
            copy[i][j] = m*copy[i][j]
        }
    }

    return copy.map { row in
        return row.last!
    }
}

// This function takes an array of xy-points, and constructs
// an augmented matrix representing a set of linear equations
// that satisfy all the conditions necessary to construct a
// cubic spline. For now, this implementation only considers
// a so-called natural spline. Implementation modeled on:
//
// https://timodenk.com/blog/cubic-spline-interpolation/
@_spi(Testing) public func makeCubicSplineMatrix(_ xyPoints: [Point2D]) -> [[Double]] {
    var matrix: [[Double]] = []
    let columnCount = (xyPoints.count-1)*4 + 1

    // Form the 2n equations representing:
    //
    //     fᵢ(xᵢ) = yᵢ
    //     fᵢ(xᵢ₊₁) = yᵢ₊₁
    for i in 0..<xyPoints.count-1 {
        for j in 0...1 {
            var row = Array(repeating: 0.0, count: columnCount)
            let (x, y) = xyPoints[i+j]
            row[i*4] = x*x*x
            row[i*4+1] = x*x
            row[i*4+2] = x
            row[i*4+3] = 1.0
            row[columnCount-1] = y
            matrix.append(row)
        }
    }

    // Form the n-1 equations representing:
    //
    //     fᵢ′(xᵢ₊₁) = fᵢ₊₁′(xᵢ₊₁)
    for i in 0..<xyPoints.count-2 {
        var row = Array(repeating: 0.0, count: columnCount)
        let (x, _) = xyPoints[i+1]
        row[i*4] = 3.0*x*x
        row[i*4+1] = 2.0*x
        row[i*4+2] = 1.0
        row[i*4+4] = -3.0*x*x
        row[i*4+5] = -2.0*x
        row[i*4+6] = -1.0
        matrix.append(row)
    }

    // Form the n-1 equations representing:
    //
    //     fᵢ′′(xᵢ₊₁) = fᵢ₊₁′′(xᵢ₊₁)
    for i in 0..<xyPoints.count-2 {
        var row = Array(repeating: 0.0, count: columnCount)
        let (x, _) = xyPoints[i+1]
        row[i*4] = 6.0*x
        row[i*4+1] = 2.0
        row[i*4+4] = -6.0*x
        row[i*4+5] = -2.0
        matrix.append(row)
    }

    // Form the 2 equations representing:
    //
    //     f₀′′(x₀) = 0
    //     fₙ₋₁′′(xₙ) = 0
    //
    // ... where n represents the number of points passed in
    for (pointIndex, functionIndex) in [(0, 0), (xyPoints.count-1, xyPoints.count-2)] {
        var row = Array(repeating: 0.0, count: columnCount)
        let (x, _) = xyPoints[pointIndex]
        row[functionIndex*4] = 6.0*x
        row[functionIndex*4+1] = 2.0
        matrix.append(row)
    }

    // Return the matrix representing a system of equations of:
    //
    //     2n + (n-1) + (n-1) + 2 = 4n
    //
    // unknowns, a₀, b₀, c₀, d₀, a₁, b₁, c₁, d₁,... aₙ, bₙ, cₙ, dₙ
    return matrix
}

@_spi(Testing) public typealias CubicPolynomialCoefficients = (Double, Double, Double, Double)
@_spi(Testing) public typealias CubicSplineFunction = (Double) -> Double

// This function takes set of xy-points, and an array of tuples representing
// the coefficients of a cubic function of the form, ax³ + bx² + cx + d,
// and returns a piecewise-defined function for the range of x values
// established by those points.
@_spi(Testing) public func makePiecewiseCubicSplineFunction(_ xyPoints: [Point2D], _ coefficientsList: [CubicPolynomialCoefficients]) -> CubicSplineFunction? {
    guard let (_, y0) = xyPoints.first else {
        return nil
    }
    guard coefficientsList.count == xyPoints.count - 1 else {
        return nil
    }

    // Since Swift does not have any macros or any other templating
    // strategy, we resort to building a function using nested if-blocks.
    // For example, if we pass in the points: [(x₀, y₀), (x₁, y₁), (x₂, y₂)],
    // and the list of coefficients, [(a₀, b₀, c₀, d₀), (a₁, b₁, c₁, d₁)],
    // then we will construct the following function (in pseudocode):
    //
    //     f(x) =
    //         if x > x₁ {
    //             return a₁x³ + b₁x² + c₁x + d₁
    //         } else {
    //             if x > x₀ {
    //                 return a₀x³ + b₀x² + c₀x + d₀
    //             } else {
    //                 return y₀
    //             }
    //         }
    return zip(coefficientsList, xyPoints)
        .reduce({ (x: Double) -> Double in y0 }) { prevF, pair in
            let ((a, b, c, d), (xi, _)) = pair

            func f(x: Double) -> Double {
                if x >= xi {
                    return a*x*x*x + b*x*x + c*x + d
                } else {
                    return prevF(x)
                }
            }

            return f
        }
}
