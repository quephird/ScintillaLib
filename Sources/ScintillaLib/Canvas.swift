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

    public init(_ width: Int, _ height: Int) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: Color(0.0, 0.0, 0.0), count: width*height)
    }

    @_spi(Testing) public func getPixel(_ x: Int, _ y: Int) -> Color {
        self.pixels[x + y*width]
    }

    @_spi(Testing) public mutating func setPixel(_ x: Int, _ y: Int, _ color: Color) {
        self.pixels[x + y*width] = color
    }
}
