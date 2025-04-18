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
            width: 400,
            height: 400,
            viewAngle: PI/3,
            from: Point(0, 3, -4),
            to: Point(0, 0, 0),
            up: Vector(0, 1, 0))
        .focalBlur(FocalBlur(
            focalDistance: 5.0,
            aperture: 0.2,
            samples: 50))
        PointLight(position: Point(-10, 10, -10))
        Sphere()
            .material(.uniform(1, 0, 0))
        Sphere()
            .material(.uniform(0, 1, 0))
            .translate(-3, 0, 4)
        Sphere()
            .material(.uniform(0, 0, 1))
            .translate(3, 0, 4)
        Sphere()
            .material(.uniform(1, 1, 0))
            .translate(-2, 0, -2)
        Sphere()
            .material(.uniform(0, 1, 1))
            .translate(2, 0, -2)
        Plane()
            .translate(0.0, -1.0, 0.0)
    }
}
