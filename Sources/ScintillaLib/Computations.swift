//
//  Computations.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

public struct Computations {
    @_spi(Testing) public var t: Double
    @_spi(Testing) public var object: any Shape
    @_spi(Testing) public var point: Point
    @_spi(Testing) public var overPoint: Point
    @_spi(Testing) public var underPoint: Point
    @_spi(Testing) public var eye: Vector
    @_spi(Testing) public var normal: Vector
    @_spi(Testing) public var reflected: Vector
    @_spi(Testing) public var isInside: Bool
    @_spi(Testing) public var n1: Double
    @_spi(Testing) public var n2: Double
}
