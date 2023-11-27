//
//  TDOR.swift
//
//
//  Created by Danielle Kefford on 11/20/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct TDOR: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(600, 600, PI/3, .view(
            Point(0, 0, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ImplicitSurface(bottomFrontLeft: (-0.5, 0.0, -0.5),
                        topBackRight: (0.5, 1.0, 0.5), { x, y, z in
            pow(x, 2.0) + pow(z, 2.0) - pow(y, 3.0) + pow(y, 4.0)
        }) // Flame
            .scale(0.8, 1.5, 0.8)
            .rotateZ(PI)
            .shear(0.0, 0.0, 1.0, 1.0, 0.0, 0.0)
            .translate(0.1, 2.5, 0.1)
            .material(.solidColor(1.0, 0.6, 0.0))
        Cylinder(bottomY: -2.0, topY: 1.0, isCapped: true) // Candle body
            .scale(0.4, 1.0, 0.4)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Cylinder(bottomY: -0.5, topY: 1.0, isCapped: true) // Melted wax streak 1
            .scale(0.1, 1.0, 0.1)
            .translate(-0.24, 0.0, -0.24)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Sphere() // Drip at end of wax streak 1
            .scale(0.1, 0.2, 0.1)
            .translate(-0.24, -0.5, -0.24)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Cylinder(bottomY: 0.5, topY: 1.0, isCapped: true) // Melted wax streak 2
            .scale(0.1, 1.0, 0.1)
            .translate(-0.04, 0.0, -0.31)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Sphere() // Drip at end of wax streak 2
            .scale(0.1, 0.2, 0.1)
            .translate(-0.04, 0.5, -0.31)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Cylinder(bottomY: -2.0, topY: 1.0, isCapped: true) // Melted wax streak 3
            .scale(0.1, 1.0, 0.1)
            .translate(0.28, 0.0, -0.18)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Sphere() // Small pool of wax at end of streak 3
            .scale(0.3, 0.05, 0.3)
            .translate(0.28, -2.0, -0.18)
            .material(.solidColor(0.1, 0.3, 0.7, .hsl))
        Plane()
            .translate(0.0, -2.0, 0.0)
    }
}
