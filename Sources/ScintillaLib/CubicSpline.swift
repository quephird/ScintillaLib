//
//  CubicSpline.swift
//  
//
//  Created by Danielle Kefford on 10/30/22.
//

// This function takes an n ⨯ n+1 augmented matrix representing
// a system of n equations with n unknowns, solves them using
// Gaussian elimination, and returns the solution as an array
// of values of length n.
func solve(_ matrix: [[Double]]) -> [Double]? {
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
        // if if does not, then this matrix represents a system of
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
