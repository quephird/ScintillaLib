//
//  SphereTheHardWay.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

import Darwin
import ScintillaLib

@available(macOS 12.0, *)
@main
struct SphereTheHardWay: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 0, -5),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
            (-2, -2, -2), (2, 2, 2),
            (0, PI), (0, 2*PI),
            { (θ, ϕ) in cos(θ)*sin(ϕ) },
            { (θ, ϕ) in sin(θ)*sin(ϕ) },
            { (θ, ϕ) in cos(ϕ) })
            .material(.solidColor(0.2, 1, 0.5))
    }
}
