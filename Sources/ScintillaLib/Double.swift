//
//  Double.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/19/21.
//

import Foundation

let EPSILON = 0.00001

let PI = 3.1415926536

extension Double {
    func isAlmostEqual(_ to: Double) -> Bool {
        return abs(self - to) < EPSILON
    }
}
