//
//  QuickStart.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct QuickStart: ScintillaApp {
    var world = World {
        PointLight(position: Point(-10, 10, -10))
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 2, -2),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        Sphere()
            .material(.solidColor(1, 0, 0))
    }
}
