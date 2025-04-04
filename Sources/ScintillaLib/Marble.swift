//
//  Marble.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 3/29/25.
//

import Foundation

final public class Marble: Pattern {
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
        var noiseCoef: Double = 0.0

        for level in 1..<10 {
            let noise = perlin.noise(x: 0.05 * Double(level) * patternPoint.x,
                                     y: 0.15 * Double(level) * patternPoint.y,
                                     z: 0.05 * Double(level) * patternPoint.z)

            noiseCoef += (1.0 / Double(level)) * abs(noise)
        }

        noiseCoef = 0.5 * sin(0.01*(patternPoint.x + patternPoint.y) + noiseCoef) + 0.5

        let color = self.firstColor.multiplyScalar(noiseCoef).add(self.secondColor.multiplyScalar(1.0 - noiseCoef))
        return color
    }
}
