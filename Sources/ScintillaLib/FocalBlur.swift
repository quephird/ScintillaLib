//
//  FocalBlur.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 4/11/25.
//

public struct FocalBlur: Equatable {
    var focalDistance: Double
    var aperture: Double
    var samples: Int

    public init(focalDistance: Double, aperture: Double, samples: Int) {
        self.focalDistance = focalDistance
        self.aperture = aperture
        self.samples = samples
    }
}
