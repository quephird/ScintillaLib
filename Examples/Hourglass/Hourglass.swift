//
//  Hourglass.swift
//
//
//  Created by Danielle Kefford on 11/23/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct Hourglass: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 1, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
            (-1.0, -1.0, -1.0), (1.0, 1.0, 1.0),
            (0, 2*PI), (0, 2*PI),
            0.001, 0.3,
            { (u, v) in cos(u)*sin(2*v) },
            { (u, v) in sin(v) },
            { (u, v) in sin(u)*sin(2*v) })
        .material(.solidColor(0.9, 0.5, 0.5, .hsl))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -1.0, 0)
    }
}
