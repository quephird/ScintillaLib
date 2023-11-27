//
//  Blob.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct Blob: ScintillaApp {
    var world = World {
        PointLight(position: Point(-10, 10, -10))
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 0, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        ImplicitSurface(bottomFrontLeft: (-2, -2, -2),
                        topBackRight: (2, 2, 2), { x, y, z in
            x*x + y*y + z*z + sin(4*x) + sin(4*y) + sin(4*z) - 1.0
        })
            .material(.solidColor(0.2, 1, 0.5))
    }
}
