//
//  File.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct Vase: ScintillaApp {
    var world = World {
        PointLight(position: Point(-5, 5, -5))
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 7, -10),
               to: Point(0, 2, 0),
               up: Vector(0, 1, 0))
        SurfaceOfRevolution(yzPoints: [(0.0, 2.0), (1.0, 2.0), (2.0, 1.0), (3.0, 0.5), (6.0, 0.5)])
            .material(.solidColor(0.5, 0.6, 0.8))
        Plane()
            .material(.solidColor(1, 1, 1))
    }
}
