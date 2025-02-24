//
//  CheckeredSphere.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 2/23/25.
//

import Darwin
import ScintillaLib

let checkered = Checkered3D(.white, .black, .identity)
    .scale(0.5, 0.5, 0.5)

@available(macOS 12.0, *)
@main
struct RainbowBall: ScintillaApp {

    var world = World {
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 2, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-10, 10, -10))
        Sphere()
            .material(checkered)
        Plane()
            .translate(0.0, -1.0, 0.0)
    }
}
