//
//  QuickStart.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct QuickStart: ScintillaApp {
    var body = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 2, -2),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        Sphere()
            .material(.solidColor(1, 0, 0))
    }
}
