//
//  Ray.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct Ray {
    @_spi(Testing) public var origin: Point
    @_spi(Testing) public var direction: Vector

    public init(_ origin: Point, _ direction: Vector) {
        self.origin = origin
        self.direction = direction
    }

    @_spi(Testing) public func position(_ t: Double) -> Point {
        self.origin.add(self.direction.multiply(t))
    }

    @_spi(Testing) public func transform(_ m: Matrix4) -> Ray {
        Ray(
            m.multiply(self.origin),
            m.multiply(self.direction)
        )
    }
}
