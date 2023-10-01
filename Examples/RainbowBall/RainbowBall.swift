//
//  RainbowBall.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import Darwin
import ScintillaLib

@main
struct QuickStart: ScintillaApp {
    var body = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 2, -2),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        Sphere()
            .material(.colorFunction(.hsl) { x, y, z in
                ((atan2(z, x)+PI)/PI/2.0, 1.0, 0.5)
            })
    }
}
