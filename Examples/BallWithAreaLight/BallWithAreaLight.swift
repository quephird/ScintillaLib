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
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 2, -5),
               to: Point(0, 1, 0),
               up: Vector(0, 1, 0))
        AreaLight(corner: Point(-5, 5, -5),
                  uVec: Vector(2, 0, 0),
                  uSteps: 10,
                  vVec: Vector(0, 2, 0),
                  vSteps: 10)
        Sphere()
            .translate(0, 1, 0)
            .material(.uniform(1, 0, 0))
        Plane()
            .material(.uniform(1, 1, 1))
    }
}
