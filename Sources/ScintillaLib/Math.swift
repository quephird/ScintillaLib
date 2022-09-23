//
//  Math.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/7/22.
//

import Foundation

func isAlmostZero(_ n: Double) -> Bool {
    return abs(n) < 1e-9
}

func cbrt(_ n: Double) -> Double {
    if n>=0 {
        return pow(n, 1.0/3.0)
    } else {
        return -pow(-n, 1.0/3.0)
    }
}

func solveQuadratic(_ a: Double, _ b: Double, _ c: Double) -> [Double] {
    let discriminant = b*b - 4*a*c

    if isAlmostZero(discriminant) {
        // One double root
        return [-b/2/a]
    } else if discriminant < 0 {
        // No real roots
        return []
    } else {
        // Both real roots
        return [
            (-b - sqrt(discriminant))/2/a,
            (-b + sqrt(discriminant))/2/a
        ]
    }
}

func solveCubic(_ c3: Double, _ c2: Double, _ c1: Double, _ c0: Double) -> [Double] {
    // First put the cubic in the form:
    //
    //     x³ + ax² + bx + c
    let a = c2/c3
    let b = c1/c3
    let c = c0/c3

    // ... then put it in the "depressed" form:
    //
    //     t³ + pt + q
    let p = 1.0/3.0 * (1.0/3.0 * a * a - b);
    let q = 1.0/2.0 * (2.0/27.0 * a * a * a - 1.0/3.0 * a * b + c);
    let discriminant = q*q - p*p*p

    var roots: [Double] = []
    if isAlmostZero(discriminant) {
        if isAlmostZero(q) {
            // One triple root
            roots = [0.0];
        } else {
            // One single and one double root
            let u = cbrt(-q)
            roots = [2 * u, -u];
        }
    } else if discriminant < 0 {
        // Casus irreducibilis: three real roots
        let phi = 1.0/3.0 * acos(q / sqrt(p * p * p))
        let t = -2.0 * sqrt(p);

        roots = [t * cos(phi),
                 -t * cos(phi + PI/3.0),
                 -t * cos(phi - PI/3.0)]
    } else {
        // Only one real solution exists
        let sqrtD = sqrt(discriminant)
        let u = cbrt(sqrtD - q)
        let v = -cbrt(sqrtD + q)

        roots = [u + v];
    }

    return roots.map { root in
        root - 1.0/3.0 * a
    }
}

func solveQuartic(_ c4: Double, _ c3: Double, _ c2: Double, _ c1: Double, _ c0: Double) -> [Double] {
    // First put the quartic in the form:
    //
    //     x⁴ + ax³ + bx² + cx + d
    let a = c3/c4
    let b = c2/c4
    let c = c1/c4
    let d = c0/c4

    // ... next put it in the "depressed" form:
    //
    //     t⁴ + px² + qx + r
    let p = -3.0/8.0 * a * a + b
    let q = 1.0/8.0 * a * a * a - 1.0/2.0 * a * b + c
    let r = -3.0/256.0 * a * a * a * a + 1.0/16.0 * a * a * b - 1.0/4.0 * a * c + d

    var roots: [Double] = []

    if isAlmostZero(r) {
        // Equation is of the form:
        //
        //     t(t³ + pt + q) = 0
        //
        // ... and so one root is zero and the others can be
        // found by solving the cubic factor.
        roots = solveCubic(1.0, 0.0, p, q)
        roots.append(0.0)
    } else if isAlmostZero(q) {
        // Equation is of the form:
        //
        //     t⁴ + pt² + r = 0
        //
        // ... and the roots can be found by solving a quadratic in t²
        let resolventRoots = solveQuadratic(1, p, r)
        for root in resolventRoots {
            if root >= 0.0 {
                roots.append(sqrt(root))
                roots.append(-sqrt(root))
            }
        }
    } else {
        // Resort to Ferrari's method...
        let resolvantRoots = solveCubic(
            1,
            p,
            p*p/4.0 - r,
            -q*q/8.0
        )

        // Choose the first root of the resolvant cubic...
        guard let z = resolvantRoots.first(where: { root in
            root > 0.0
        }) else {
            return []
        }

        // ... then determine the roots of each quadratic
        roots = solveQuadratic(
            1,
            sqrt(2*z),
            p/2.0 + z - q/2.0/sqrt(2*z)
        )
        roots.append(contentsOf: solveQuadratic(
            1,
            -sqrt(2*z),
            p/2.0 + z + q/2.0/sqrt(2*z)
        ))
    }

    var dedupedRoots: [Double] = []
    for root in roots {
        if dedupedRoots.allSatisfy({ dedupedRoot in
            !isAlmostZero(dedupedRoot - root)
        }) {
            dedupedRoots.append(root)
        }
    }

    return dedupedRoots.map { root in
        root - 1.0/4.0 * a
    }
}
