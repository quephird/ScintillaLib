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
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 0, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-5, 5, -5))
        ImplicitSurface(center: (0.0, 0.0, 0.0), radius: 2.0) { x, y, z in
            4.0*(φ*φ*x*x-y*y)*(φ*φ*y*y-z*z)*(φ*φ*z*z-x*x) - (1.0+2.0*φ)*(x*x+y*y+z*z-1.0)*(x*x+y*y+z*z-1.0)
        }
            .material(.solidColor(0.9, 0.9, 0.0))
    }
}
