//
//  FishEye.swift
//  
//
//  Created by Danielle Kefford on 11/28/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct FishEye: ScintillaApp {
    var world = World {
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 0, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-10, 10, -10))
        Sphere()
            .material(
                .solidColor(0, 0, 0)
                .transparency(1.0)
                .refractive(1.5))
            .scale(2, 2, 2)
            .translate(0, 0, -5.5)
            .intersection {
                Sphere()
                    .material(
                        .solidColor(0, 0, 0)
                        .transparency(1.0)
                        .refractive(1.5))
                    .scale(2, 2, 2)
                    .translate(0, 0, -2.5)
            }
        Cube()
            .material(.solidColor(1, 0, 0))
            .translate(-3, 0, 8)
        Cube()
            .material(.solidColor(0, 1, 0))
            .translate(0, 0, 8)
        Cube()
            .material(.solidColor(0, 0, 1))
            .translate(3, 0, 8)
        Plane()
            .translate(0, -1, 2)
    }
}
