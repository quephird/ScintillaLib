//
//  HappyHalloween.swift
//  
//
//  Created by Danielle Kefford on 10/31/23.
//

import Darwin
import ScintillaLib

func pumpkin(x: Double, y: Double, z: Double) -> Double {
    y*y + (x*x + z*z - 1.0)*(1.0 - 0.5*exp(-10.0*(x*x + z*z))) + 0.02*pow(sin(20.0*atan(x/(sqrt(x*x + z*z) + z))), 20.0)
}

@available(macOS 12.0, *)
@main
struct HappyHalloween: ScintillaApp {
    var world: World = World {
        PointLight(Point(-2, 5, -5))
        Camera(600, 600, PI/3, .view(
            Point(0, 2, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ImplicitSurface((0.0, 0.0, 0.0), 2.0) { x, y, z in
            pumpkin(x: x, y: y, z: z)
        }
            .material(.solidColor(1.0, 0.5, 0.0))
            .scale(2.0, 1.5, 2.0)
            .difference {
                Prism(-1.0, 1.5, [(0.0, 0.5), (-0.25, 0), (0.25, 0.0)])
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(-0.5, 0.4, -1.5)
                Prism(-1.0, 1.5, [(0.0, 0.5), (-0.25, 0), (0.25, 0.0)])
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.5, 0.4, -1.5)
                Prism(-1.0, 1.5, [(0.0, 0.25), (-0.1, 0), (0.1, 0.0)])
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.0, 0.3, -1.5)
                Prism(-1.0, 1.5, [(-0.75, 0.0), (-0.5, -0.25),
                                 (-0.4, -0.25), (-0.4, -0.15), (-0.3, -0.15), (-0.3, -0.25),
                                 (0.5, -0.25), (0.75, 0.0),
                                 (0.4, 0.0), (0.4, -0.1), (0.3, -0.1), (0.3, 0.0)])
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.0, 0.1, -1.7)
            }
        Cylinder(0.0, 1.0, true)
            .material(.solidColor(0.9, 0.9, 0.7))
            .scale(0.2, 1.0, 0.2)
            .rotateX(0.1)
            .rotateZ(0.1)
            .translate(0.0, 1.0, 0.0)
    }
}
