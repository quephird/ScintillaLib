//
//  Die.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct Die: ScintillaApp {
    var world: World {
        let orange: Material = .solidColor(1, 0.5, 0)
            .reflective(0.2)

        return World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 5, -10),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Cube()
                .material(orange)
                .intersection {
                    Sphere()
                        .material(orange)
                        .scale(1.55, 1.55, 1.55)
                    Cylinder(bottomY: -2, topY: 2, isCapped: true)
                        .material(orange)
                        .scale(1.35, 1.35, 1.35)
                    Cylinder(bottomY: -2, topY: 2, isCapped: true)
                        .material(orange)
                        .scale(1.35, 1.35, 1.35)
                        .rotateX(PI/2)
                    Cylinder(bottomY: -2, topY: 2, isCapped: true)
                        .material(orange)
                        .scale(1.35, 1.35, 1.35)
                        .rotateZ(PI/2)
                }.difference {
                    for (x, y, z) in [
                        // face with six dimples
                        (-0.6, 1.0, 0.6),
                        (-0.6, 1.0, 0.0),
                        (-0.6, 1.0, -0.6),
                        (0.6, 1.0, 0.6),
                        (0.6, 1.0, 0.0),
                        (0.6, 1.0, -0.6),
                        // face with five dimples
                        (0.0, 0.0, -1.0),
                        (0.6, 0.6, -1.0),
                        (0.6, -0.6, -1.0),
                        (-0.6, 0.6, -1.0),
                        (-0.6, -0.6, -1.0),
                        // face with four dimples
                        (1.0, 0.6, 0.6),
                        (1.0, 0.6, -0.6),
                        (1.0, -0.6, 0.6),
                        (1.0, -0.6, -0.6),
                        // face with three dimples
                        (-1.0, 0.6, 0.6),
                        (-1.0, 0, 0),
                        (-1.0, -0.6, -0.6),
                        // face with two dimples
                        (0.6, 0.6, 1.0),
                        (-0.6, -0.6, 1.0),
                        // face with one dimple
                        (0.0, -1.0, 0.0),
                    ] {
                        Sphere()
                            .material(.solidColor(1, 1, 1))
                            .scale(0.2, 0.2, 0.2)
                            .translate(x, y, z)
                    }
                }
                .rotateY(PI/3)
                .translate(0.0, 1.0, 0.0)
            Plane()
                .material(.pattern(Checkered2D(.black, .white, .identity)))
        }
    }
}
