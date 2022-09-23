//
// Created by Danielle Kefford on 11/21/21.
//

import XCTest

class Matrix2Tests: XCTestCase {
    func testDeterminant() throws {
        let m = Matrix2(
            1, 5,
            -3, 2
        )
        let actualValue = m.determinant()
        let expectedValue = 17.0
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}

class Matrix3Tests: XCTestCase {
    func testSubmatrix() throws {
        let m = Matrix3(
            1, 5, 0,
            -3, 2, 7,
            0, 6, -3
        )
        let actualValue = m.submatrix(0, 2)
        let expectedValue = Matrix2(
            -3, 2,
            0, 6
        )
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testMinor() throws {
        let m = Matrix3(
            3, 5, 0,
            2, -1, -7,
            6, -1, 5
        )
        let actualValue = m.minor(1, 0)
        let expectedValue = 25.0
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testCofactor() throws {
        let m = Matrix3(
            3, 5, 0,
            2, -1, -7,
            6, -1, 5
        )
        let actualValue = m.cofactor(0, 0)
        let expectedValue = -12.0
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testDeterminant() throws {
        let m = Matrix3(
            1, 2, 6,
            -5, 8, -4,
            2, 6, 4
        )
        let actualValue = m.determinant()
        let expectedValue = -196.0
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }
}

class Matrix4Tests: XCTestCase {
    func testIsAlmostEqual() throws {
        let m1 = Matrix4(
            1, 2, 3, 4,
            5, 6, 7, 8,
            9, 8, 7, 6,
            5, 4, 3, 2
        )
        let m2 = Matrix4(
            1, 2, 3, 4,
            5, 6, 7, 8,
            9, 8, 7, 6,
            5, 4, 3, 2
        )
        XCTAssert(m1.isAlmostEqual(m2))
    }

    func testMultiplyMatrix() throws {
        let m1 = Matrix4(
            1, 2, 3, 4,
            5, 6, 7, 8,
            9, 8, 7, 6,
            5, 4, 3, 2
        )
        let m2 = Matrix4(
            -2, 1, 2, 3,
            3, 2, 1, -1,
            4, 3, 6, 5,
            1, 2, 7, 8
        )
        let expectedValue = Matrix4(
            20, 22, 50, 48,
            44, 54, 114, 108,
            40, 58, 110, 102,
            16, 26, 46, 42
        )
        let actualValue = m1.multiplyMatrix(m2)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testMultiplyTuple() throws {
        let m = Matrix4(
            1, 2, 3, 4,
            2, 4, 4, 2,
            8, 6, 4, 1,
            0, 0, 0, 1
        )
        let t = Tuple4(1, 2, 3, 1)
        let actualValue = m.multiplyTuple(t)
        let expectedValue = Tuple4(18, 24, 33, 1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testTranspose() throws {
        let m = Matrix4(
            0, 9, 3, 0,
            9, 8, 0, 8,
            1, 8, 5, 3,
            0, 0, 5, 8
        )
        let actualValue = m.transpose()
        let expectedValue = Matrix4(
            0, 9, 1, 0,
            9, 8, 8, 0,
            3, 0, 5, 5,
            0, 8, 3, 8
        )
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testSubmatrix() throws {
        let m = Matrix4(
            -6, 1, 1, 6,
            -8, 5, 8, 6,
            -1, 0, 8, 2,
            -7, 1, -1, 1
        )
        let actualValue = m.submatrix(2, 1)
        let expectedValue = Matrix3(
            -6, 1, 6,
            -8, 8, 6,
            -7, -1, 1
        )
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testDeterminant() throws {
        let m = Matrix4(
            -2, -8, 3, 5,
            -3, 1, 7, 3,
            1, 2, -9, 6,
            -6, 7, 7, -9
        )
        let actualValue = m.determinant()
        let expectedValue = -4071.0
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testInverse() throws {
        let m = Matrix4(
            8, -5, 9, 2,
            7, 5, 6, 1,
            -6, 0, 9, 6,
            -3, 0, -9, -4
        )
        let actualValue = m.inverse()
        let expectedValue = Matrix4(
            -0.15385, -0.15385, -0.28205, -0.53846,
            -0.07692, 0.12308, 0.02564, 0.03077,
            0.35897, 0.35897, 0.43590, 0.92308,
            -0.69231, -0.69231, -0.76923, -1.92308
        )
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testTranslation() throws {
        let transform = Matrix4.translation(5, -3, 2)
        let p = point(-3, 4, 5)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(2, 1, 7)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testTranslationInverse() throws {
        let transform = Matrix4.translation(5, -3, 2).inverse()
        let p = point(-3, 4, 5)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(-8, 7, 3)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testTranslationDoesNotAffectVectors() throws {
        let transform = Matrix4.translation(5, -3, 2).inverse()
        let v = vector(-3, 4, 5)
        let actualValue = transform.multiplyTuple(v)
        XCTAssert(actualValue.isAlmostEqual(v))
    }

    func testScalingPoint() throws {
        let transform = Matrix4.scaling(2, 3, 4)
        let p = point(-4, 6, 8)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(-8, 18, 32)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testScalingVector() throws {
        let transform = Matrix4.scaling(2, 3, 4)
        let v = vector(-4, 6, 8)
        let actualValue = transform.multiplyTuple(v)
        let expectedValue = vector(-8, 18, 32)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testScalingInverse() throws {
        let transform = Matrix4.scaling(2, 3, 4).inverse()
        let v = vector(-4, 6, 8)
        let actualValue = transform.multiplyTuple(v)
        let expectedValue = vector(-2, 2, 2)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testRotationX() throws {
        let p = point(0, 1, 0)
        let halfQuarter = Matrix4.rotationX(PI/4)
        let fullQuarter = Matrix4.rotationX(PI/2)

        var actualValue = halfQuarter.multiplyTuple(p)
        var expectedValue = point(0, sqrt(2)/2, sqrt(2)/2)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))

        actualValue = fullQuarter.multiplyTuple(p)
        expectedValue = point(0, 0, 1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testRotationY() throws {
        let p = point(0, 0, 1)
        let halfQuarter = Matrix4.rotationY(PI/4)
        let fullQuarter = Matrix4.rotationY(PI/2)

        var actualValue = halfQuarter.multiplyTuple(p)
        var expectedValue = point(sqrt(2)/2, 0, sqrt(2)/2)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))

        actualValue = fullQuarter.multiplyTuple(p)
        expectedValue = point(1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testRotationZ() throws {
        let p = point(0, 1, 0)
        let halfQuarter = Matrix4.rotationZ(PI/4)
        let fullQuarter = Matrix4.rotationZ(PI/2)

        var actualValue = halfQuarter.multiplyTuple(p)
        var expectedValue = point(-sqrt(2)/2, sqrt(2)/2, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))

        actualValue = fullQuarter.multiplyTuple(p)
        expectedValue = point(-1, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingXy() throws {
        let transform = Matrix4.shearing(1, 0, 0, 0, 0, 0)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(5, 3, 4)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingXz() throws {
        let transform = Matrix4.shearing(0, 1, 0, 0, 0, 0)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(6, 3, 4)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingYx() throws {
        let transform = Matrix4.shearing(0, 0, 1, 0, 0, 0)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(2, 5, 4)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingYz() throws {
        let transform = Matrix4.shearing(0, 0, 0, 1, 0, 0)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(2, 7, 4)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingZx() throws {
        let transform = Matrix4.shearing(0, 0, 0, 0, 1, 0)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(2, 3, 6)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShearingZy() throws {
        let transform = Matrix4.shearing(0, 0, 0, 0, 0, 1)
        let p = point(2, 3, 4)
        let actualValue = transform.multiplyTuple(p)
        let expectedValue = point(2, 3, 7)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testChainingTransformations() throws {
        let p = point(1, 0, 1)
        let rx = Matrix4.rotationX(PI/2)
        let s = Matrix4.scaling(5, 5, 5)
        let t = Matrix4.translation(10, 5, 7)
        let fullTransform = t.multiplyMatrix(s).multiplyMatrix(rx)
        let actualValue = fullTransform.multiplyTuple(p)
        let expectedValue = point(15, 0, 7)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testViewWithDefaultOrientation() throws {
        let from = point(0, 0, 0)
        let to = point(0, 0, -1)
        let up = vector(0, 1, 0)
        let actualValue = Matrix4.view(from, to, up)
        let expectedValue = Matrix4.identity
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testViewLookingInPostiveZDirection() throws {
        let from = point(0, 0, 0)
        let to = point(0, 0, 1)
        let up = vector(0, 1, 0)
        let actualValue = Matrix4.view(from, to, up)
        let expectedValue = Matrix4.scaling(-1, 1, -1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testViewMovesWorld() throws {
        let from = point(0, 0, 8)
        let to = point(0, 0, 1)
        let up = vector(0, 1, 0)
        let actualValue = Matrix4.view(from, to, up)
        let expectedValue = Matrix4.translation(0, 0, -8)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testViewArbitraryTransformation() throws {
        let from = point(1, 3, 2)
        let to = point(4, -2, 8)
        let up = vector(1, 1, 0)
        let actualValue = Matrix4.view(from, to, up)
        let expectedValue = Matrix4(
            -0.50709, 0.50709, 0.67612,  -2.36643,
            0.76772,  0.60609, 0.12122,  -2.82843,
            -0.35857, 0.59761, -0.71714, 0.00000,
            0.00000,  0.00000, 0.00000,  1.00000
        )
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

}
