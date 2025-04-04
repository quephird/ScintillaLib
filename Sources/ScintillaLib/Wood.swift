//
//  Wood.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 4/1/25.
//

import Foundation

final public class Wood: Pattern {
    private var firstColor: Color
    private var secondColor: Color
    private var perlin = PerlinNoise()

    public init(_ firstColor: Color,
                _ secondColor: Color,
                _ transform: Matrix4, properties: MaterialProperties = MaterialProperties()) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform, properties)
    }

    public override func copy() -> Self {
        return .init(firstColor, secondColor, transform, properties: properties)
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        var grain = 5.0 * self.perlin.noise(x: patternPoint.x, y: patternPoint.y, z: patternPoint.z)
        grain = grain - floor(grain)

        let color = self.firstColor.multiplyScalar(grain).add(self.secondColor.multiplyScalar(1.0 - grain))
        return color
    }
}
