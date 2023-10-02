//
//  Blob.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import Darwin
import ScintillaLib

@main
struct Blob: ScintillaApp {
    var body = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 0, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ImplicitSurface((-2, -2, -2), (2, 2, 2), { x, y, z in
            x*x + y*y + z*z + sin(4*x) + sin(4*y) + sin(4*z) - 1.0
        })
            .material(.solidColor(0.2, 1, 0.5))
    }
}
