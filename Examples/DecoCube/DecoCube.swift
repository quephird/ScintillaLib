//
//  DecoCube.swift
//
//
//  Created by Danielle Kefford on 11/26/23.
//

import Darwin
import ScintillaLib

func decoCubeShape(_ x: Double, _ y: Double, _ z: Double) -> Double {
    let a = 2.2
    let b = 1.0
    let c = 1.2
    return (pow(x*x + y*y - a*a, 2.0) + pow(z*z - 1.0, 2.0))*(pow(y*y + z*z - a*a, 2.0) + pow(x*x - 1.0, 2.0))*(pow(z*z + x*x - a*a, 2.0) + pow(y*y - 1.0, 2.0)) - c*(1.0 + b*(x*x + y*y + z*z))
}

func decoCubeColor(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
    return (pow(x*x + y*y + z*z, 0.5)/3.0, 1.0, 0.5)
}

@main
struct DecoCube: ScintillaApp {
    var camera = Camera(width: 600,
                        height: 600,
                        viewAngle: PI/3,
                        from: Point(2, 1, -6),
                        to: Point(0, 0, 0),
                        up: Vector(0, 1, 0))

    var world = World {
        PointLight(position: Point(-10, 10, -10))
        ImplicitSurface(bottomFrontLeft: (-2.5, -2.5, -2.5),
                        topBackRight: (2.5, 2.5, 2.5), { x, y, z in
            decoCubeShape(x, y, z)
        })
            .material(.colorFunction(.hsl) { x, y, z in
                decoCubeColor(x, y, z)
            })
        Plane()
            .translate(0, -2.5, 0)
    }
}
