//
//  FocalBlur.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 4/13/25.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct FocalBlurExample: ScintillaApp {
    var world = World {
        Camera(
            width: 600,
            height: 600,
            viewAngle: PI/3,
            from: Point(0, 6, -8),
            to: Point(0, 0, 0),
            up: Vector(0, 1, 0))
        .focalBlur(focalDistance: 10.0,
                   aperture: 0.2,
                   samples: 50)
        PointLight(position: Point(-10, 10, -10))
        Sphere()
            .material(.uniform(1, 0, 0))
            .translate(-4.5, 0, 4.5)
        Sphere()
            .material(.uniform(1, 0.5, 0))
            .translate(-3.0, 0, 3.0)
        Sphere()
            .material(.uniform(1, 1, 0))
            .translate(-1.5, 0, 1.5)
        Sphere()
            .material(.uniform(0, 1, 0))
        Sphere()
            .material(.uniform(0, 0, 1))
            .translate(1.5, 0, -1.5)
        Sphere()
            .material(.uniform(0.25, 0, 1))
            .translate(3, 0, -3)
        Sphere()
            .material(.uniform(0.5, 0, 1))
            .translate(4.5, 0, -4.5)
        Plane()
            .translate(0.0, -1.0, 0.0)
    }
}
