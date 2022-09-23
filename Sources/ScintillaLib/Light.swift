//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

struct Light {
    var position: Tuple4
    var intensity: Color

    init(_ position: Tuple4) {
        self.position = position
        self.intensity = .white
    }

    init(_ position: Tuple4, _ intensity: Color) {
        self.position = position
        self.intensity = intensity
    }
}
