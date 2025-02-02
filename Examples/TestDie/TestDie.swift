//
//  TestDie.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 1/31/25.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct Die: ScintillaApp {
    var world: World {
        let dimple =
            Sphere()
                .material(.solidColor(1, 1, 1))
                .scale(0.2, 0.2, 0.2)

        return World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 3, -7),
                   to: Point(0, 1, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-5, 10, -10))
            Superellipsoid(e: 0.15, n: 0.15)
//            Cube()
                .material(
                    .solidColor(0.8, 0.5, 0.2, .rgb)
                    .transparency(1.0)
                    .shininess(1.0)
                    .refractive(1.5))
                .translate(0.0, 1.0, 0.0)
                .difference {
                    dimple
                        .translate(0.0, 2.0, 0.0)
                    dimple
                        .translate(1.0, 0.5, -0.5)
                    dimple
                        .translate(1.0, 1.0, 0.0)
                    dimple
                        .translate(1.0, 1.5, 0.5)
                    dimple
                        .translate(-0.5, 1.5, -1.0)
                    dimple
                        .translate(0.5, 0.5, -1.0)
                }
                .rotateY(PI/4)
            Plane()
                .material(.solidColor(0.9, 0.9, 0.9))
        }
    }
}
