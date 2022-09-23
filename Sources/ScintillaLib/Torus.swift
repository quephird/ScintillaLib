//
//  Torus.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/8/22.
//

class Torus: Shape {
    var majorRadius: Double
    var minorRadius: Double

    override init( _ material: Material) {
        self.majorRadius = 2.0
        self.minorRadius = 1.0
        super.init(material)
    }

    init(_ material: Material, _ majorRadius: Double, _ minorRadius: Double) {
        self.majorRadius = majorRadius
        self.minorRadius = minorRadius
        super.init(material)
    }

    override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // NOTA BENE: We need to exclude the fourth "component" when
        // taking the dot product of the origin point with itself
        // because points are represented with a fourth component of 1.
        // Not doing so adds 1 to the product and throws off all subsequent
        // calculations. Ultimately, we need to improve the abstraction
        // for points and vectors.
        let oDotO = localRay.origin[0]*localRay.origin[0] +
                    localRay.origin[1]*localRay.origin[1] +
                    localRay.origin[2]*localRay.origin[2]
        let dDotD = localRay.direction.dot(localRay.direction)
        let oDotD = localRay.origin.dot(localRay.direction)
        let R2 = self.majorRadius*self.majorRadius
        let r2 = self.minorRadius*self.minorRadius
        let r2PlusR2 = R2 + r2
        let oy = localRay.origin[1]
        let dy = localRay.direction[1]

        let c4 = dDotD * dDotD
        let c3 = 4.0 * dDotD * oDotD
        let c2 = 2.0 * dDotD * (oDotO - r2PlusR2) + 4.0 * oDotD  * oDotD + 4.0 * R2 * dy * dy
        let c1 = 4.0 * oDotD * (oDotO - r2PlusR2) + 8.0 * R2 * oy * dy
        let c0 = (oDotO - r2PlusR2) * (oDotO - r2PlusR2) - 4.0 * R2 * (r2 - oy * oy)

        return solveQuartic(c4, c3, c2, c1, c0)
            .sorted()
            .map { root in
                Intersection(root, self)
            }
    }

    override func localNormal(_ localPoint: Tuple4) -> Tuple4 {
        let r2PlusR2 = self.majorRadius*self.majorRadius + self.minorRadius*self.minorRadius
        let pDotP = localPoint.dot(localPoint)

        return vector(
            4.0 * localPoint[0] * (pDotP - r2PlusR2),
            4.0 * localPoint[1] * (pDotP - r2PlusR2) + 2.0 * self.majorRadius * self.majorRadius,
            4.0 * localPoint[2] * (pDotP - r2PlusR2)
        )
            .normalize()
    }
}
