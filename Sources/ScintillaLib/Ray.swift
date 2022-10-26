//
//  Ray.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct Ray {
    var origin: Point
    var direction: Vector

    public init(_ origin: Point, _ direction: Vector) {
        self.origin = origin
        self.direction = direction
    }

    func position(_ t: Double) -> Point {
        self.origin.add(self.direction.multiplyScalar(t))
    }

    func transform(_ m: Matrix4) -> Ray {
        Ray(
            m.multiplyTuple(self.origin),
            m.multiplyTuple(self.direction)
        )
    }
}
