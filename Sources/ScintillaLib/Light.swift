//
//  Light.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Light {
    var position: Point { get }
    var color: Color { get }
    var fadeDistance: Double? { get }
}
