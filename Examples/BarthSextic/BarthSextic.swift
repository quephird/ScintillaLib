//
//  BarthSextic.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import Darwin
import ScintillaLib

let φ: Double = 1.61833987

@available(macOS 12.0, *)
@main
struct BarthSextic: ScintillaApp {
    var world: World = World {
        PointLight(Point(-5, 5, -5))
        Camera(400, 400, PI/3, .view(
            Point(0, 0, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ImplicitSurface((0.0, 0.0, 0.0), 2.0) { x, y, z in
            4.0*(φ*φ*x*x-y*y)*(φ*φ*y*y-z*z)*(φ*φ*z*z-x*x) - (1.0+2.0*φ)*(x*x+y*y+z*z-1.0)*(x*x+y*y+z*z-1.0)
        }
            .material(.solidColor(0.9, 0.9, 0.0))
    }
}
