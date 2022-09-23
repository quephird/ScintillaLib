//
//  Canvas.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/20/21.
//

import Foundation

public struct Canvas {
    let width: Int
    let height: Int
    var pixels: [Color]

    init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: Color(0.0, 0.0, 0.0), count: width*height)
    }

    func getPixel(_ x: Int, _ y: Int) -> Color {
        self.pixels[x + y*width]
    }

    mutating func setPixel(_ x: Int, _ y: Int, _ color: Color) {
        self.pixels[x + y*width] = color
    }
}
