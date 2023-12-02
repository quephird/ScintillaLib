//
//  ColorStrategy.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

public enum ColorStrategy {
    case solidColor(Color)
    case pattern(Pattern)
    case colorFunction(ColorFunction)
}
