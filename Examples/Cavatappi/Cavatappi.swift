//
//  Cavatappi.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct Cavatappi: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 7, -15),
            Point(0, 7, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
            (-3.5, 0, -3.5), (3.5, 15.0, 3.5),
            (0, 2*PI), (0, 7*PI),
            0.001, 1.0,
            { (u, v) in (2 + cos(u) + 0.1*cos(8*u))*cos(v) },
            { (u, v) in 2 + sin(u) + 0.1*sin(8*u) + 0.5*v },
            { (u, v) in (2 + cos(u) + 0.1*cos(8*u))*sin(v) })
        .material(.solidColor(1.0, 0.8, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -3.0, 0)
    }
}
