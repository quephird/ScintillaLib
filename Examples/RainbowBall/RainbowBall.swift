//
//  RainbowBall.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct RainbowBall: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 2, -2),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        Sphere()
            .material(.colorFunction(.hsl) { x, y, z in
                ((atan2(z, x)+PI)/PI/2.0, 1.0, 0.5)
            })
    }
}
