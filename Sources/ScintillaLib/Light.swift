//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct Light {
    var position: Tuple4
    var intensity: Color

    public init(_ position: Tuple4) {
        self.position = position
        self.intensity = .white
    }

    public init(_ position: Tuple4, _ intensity: Color) {
        self.position = position
        self.intensity = intensity
    }
}
