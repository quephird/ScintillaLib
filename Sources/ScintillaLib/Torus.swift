//
//  Torus.swift
//  Scintilla
//
//  Created by Danielle Kefford on 9/8/22.
//

@available(macOS 10.15, *)
public struct Torus: Shape {
    public var sharedProperties: SharedShapeProperties = SharedShapeProperties()

    var majorRadius: Double = 2.0
    var minorRadius: Double = 1.0

    public init(majorRadius: Double, minorRadius: Double) {
        self.majorRadius = majorRadius
        self.minorRadius = minorRadius
    }

    public func localIntersect(_ localRay: Ray) -> [Intersection] {
        // NOTA BENE: We need to exclude the fourth "component" when
        // taking the dot product of the origin point with itself
        // because points are represented with a fourth component of 1.
        // Not doing so adds 1 to the product and throws off all subsequent
        // calculations. Ultimately, we need to improve the abstraction
        // for points and vectors.
        let oDotO = localRay.origin.x*localRay.origin.x +
                    localRay.origin.y*localRay.origin.y +
                    localRay.origin.z*localRay.origin.z
        let dDotD = localRay.direction.dot(localRay.direction)
        let oDotD = localRay.origin.x*localRay.direction.x +
                    localRay.origin.y*localRay.direction.y +
                    localRay.origin.z*localRay.direction.z

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

    public func localNormal(_ localPoint: Point, _ uv: UV = .none) -> Vector {
        let r2PlusR2 = self.majorRadius*self.majorRadius + self.minorRadius*self.minorRadius
        let pDotP = localPoint.x*localPoint.x +
                    localPoint.y*localPoint.y +
                    localPoint.z*localPoint.z

        return Vector(
            4.0 * localPoint[0] * (pDotP - r2PlusR2),
            4.0 * localPoint[1] * (pDotP - r2PlusR2) + 2.0 * self.majorRadius * self.majorRadius,
            4.0 * localPoint[2] * (pDotP - r2PlusR2)
        )
            .normalize()
    }
}
