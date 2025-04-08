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

    // Code adapted from the following Web site:
    //
    //    https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/procedural-patterns-noise-part-1/simple-pattern-examples.html
    private func turbulence(_ patternPoint: Tuple4, numLayers: Int) -> Double {
        let frequencyMultiplier = 2.0
        let amplitudeMultiplier = 0.5

        var noisePoint = Point(patternPoint.x, patternPoint.y, patternPoint.z)
        var amplitude = 2.0
        var value = 0.0

        for _ in 0..<numLayers {
            value += perlin.noise(x: noisePoint.x, y: noisePoint.y, z: noisePoint.z) * amplitude
            noisePoint = Point(noisePoint.x * frequencyMultiplier,
                           noisePoint.y * frequencyMultiplier,
                           noisePoint.z * frequencyMultiplier)
            amplitude *= amplitudeMultiplier
        }

        return value
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        let turbulenceValue = self.turbulence(patternPoint, numLayers: 5)
        let noiseValue = (sin((patternPoint.x + turbulenceValue * 100.0) * 2.0 * PI / 200.0) + 1) / 2.0
        let color = self.firstColor.multiplyScalar(noiseValue).add(self.secondColor.multiplyScalar(1.0 - noiseValue))
        return color
    }
}
