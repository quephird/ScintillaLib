//
//  Rings.swift
//  
//
//  Created by Danielle Kefford on 11/22/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct Rings: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(-10, 7, -10),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
            (-6, -3, -6), (6, 3, 6),
            (0, 2*PI), (0, 2*PI),
            0.001, 3.0,
            { (u, v) in (4*(1 + 0.25*sin(3.0*v)) + cos(u))*cos(2.0*v) },
            { (u, v) in sin(u) + 2.0*cos(3*v) },
            { (u, v) in (4*(1 + 0.25*sin(3.0*v)) + cos(u))*sin(2.0*v) })
            .material(.solidColor(0.1, 1.0, 0.2))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -3.0, 0)
    }
}
