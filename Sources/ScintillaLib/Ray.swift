//
//  Ray.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct Ray {
    var origin: Tuple4
    var direction: Tuple4

    public init(_ origin: Tuple4, _ direction: Tuple4) {
        self.origin = origin
        self.direction = direction
    }

    func position(_ t: Double) -> Tuple4 {
        self.origin.add(self.direction.multiplyScalar(t))
    }

    func transform(_ m: Matrix4) -> Ray {
        Ray(
            m.multiplyTuple(self.origin),
            m.multiplyTuple(self.direction)
        )
    }
}
