//
//  BallWithAreaLight.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct BallWithAreaLight: ScintillaApp {
    var world: World = World {
        AreaLight(
            Point(-5, 5, -5),
            Vector(2, 0, 0), 10,
            Vector(0, 2, 0), 10)
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 2, -5),
               to: Point(0, 1, 0),
               up: Vector(0, 1, 0))
        Sphere()
            .translate(0, 1, 0)
            .material(.solidColor(1, 0, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
    }
}
