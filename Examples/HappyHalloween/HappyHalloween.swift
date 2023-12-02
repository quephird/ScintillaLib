//
//  HappyHalloween.swift
//  
//
//  Created by Danielle Kefford on 10/31/23.
//

import Darwin
import ScintillaLib

func pumpkin(x: Double, y: Double, z: Double) -> Double {
    y*y +
    (x*x + z*z - 1.0)*(1.0 - 0.5*exp(-10.0*(x*x + z*z))) + // Pinches the shape at the poles
    0.02*pow(sin(20.0*atan(x/(sqrt(x*x + z*z) + z))), 20.0) // Adds flattened periodic ribbing on the surface
}

func stem(x: Double, y: Double, z: Double) -> Double {
    (x*x + z*z) +
    5.0*y*(1.0 - exp(-(x*x + z*z))) - // Adds vertical taper
    0.2*sin(5.0*atan2(x, z)) - 1 // Adds periodic ribbing on the surface
}

@main
struct HappyHalloween: ScintillaApp {
    var world: World = World {
        Camera(width: 600,
               height: 600,
               viewAngle: PI/3,
               from: Point(0, 2, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-2, 5, -5))
        ImplicitSurface(center: (0.0, 0.0, 0.0), radius: 2.0) { x, y, z in
            pumpkin(x: x, y: y, z: z)
        }
            .material(.solidColor(1.0, 0.5, 0.0))
            .scale(2.0, 1.5, 2.0)
            .difference {
                Prism(bottomY: -1.0, topY: 1.5, xzPoints: [(0.0, 0.5), (-0.25, 0), (0.25, 0.0)]) // Right eye
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(-0.5, 0.4, -1.5)
                Prism(bottomY: -1.0, topY: 1.5, xzPoints: [(0.0, 0.5), (-0.25, 0), (0.25, 0.0)]) // Left eye
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.5, 0.4, -1.5)
                Prism(bottomY: -1.0, topY: 1.5, xzPoints: [(0.0, 0.25), (-0.1, 0), (0.1, 0.0)]) // Nose
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.0, 0.3, -1.5)
                Prism(bottomY: -1.0, topY: 1.5, xzPoints: [(-0.75, 0.0), (-0.5, -0.25), // Mouth
                                 (-0.4, -0.25), (-0.4, -0.15), (-0.3, -0.15), (-0.3, -0.25),
                                 (0.5, -0.25), (0.75, 0.0),
                                 (0.4, 0.0), (0.4, -0.1), (0.3, -0.1), (0.3, 0.0)])
                    .material(.solidColor(1.0, 0.8, 0.0))
                    .rotateX(-PI/2.0)
                    .translate(0.0, 0.1, -1.7)
            }
        ImplicitSurface(bottomFrontLeft: (-1.5, 0, -1.5),
                        topBackRight: (1.5, 1, 1.5)) { x, y, z in
            stem(x: x, y: y, z: z)
        }
            .material(.solidColor(0.9, 0.9, 0.7))
            .scale(0.2, 1.0, 0.2)
            .rotateX(0.1)
            .rotateZ(0.1)
            .translate(0.0, 1.0, 0.0)
    }
}
