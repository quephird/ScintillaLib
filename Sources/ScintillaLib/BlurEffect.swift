//
//  BlurEffect.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 4/21/25.
//

public enum BlurEffect: Equatable {
    case none
    case antialiasing
    case focalBlur(Double, Double, Int)
}
