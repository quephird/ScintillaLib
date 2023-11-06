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
            Point(-2, 0, -2),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
//            (-4, -4, -1), (4, 4, 1),
            (-1, -1, -1), (1, 1, 1),
            (-PI, PI), (0, 2*PI),
            { (θ, ϕ) in cos(θ)*sin(ϕ) },
            { (θ, ϕ) in sin(θ)*sin(ϕ) },
            { (θ, ϕ) in cos(ϕ) })
//            { (θ, ϕ) in 3*cos(θ)*sin(ϕ) },
//            { (θ, ϕ) in sin(θ)*sin(ϕ) },
//            { (θ, ϕ) in 2*cos(ϕ) })
//            { (θ, ϕ) in θ },
//            { (θ, ϕ) in cos(θ)*cos(ϕ) },
//            { (θ, ϕ) in cos(θ)*sin(ϕ) })
//            { (θ, ϕ) in (2 + cos(ϕ))*cos(θ) },
//            { (θ, ϕ) in (2 + cos(ϕ))*sin(θ) },
//            { (θ, ϕ) in sin(ϕ) })
//            { (θ, ϕ) in θ },
//            { (θ, ϕ) in cos(ϕ) },
//            { (θ, ϕ) in sin(ϕ) })
//            { (u, v) in 1/2*sin(2*u)*cos(v)*cos(v) },
//            { (u, v) in 1/2*sin(u)*sin(2*v) },
//            { (u, v) in 1/2*cos(u)*sin(2*v) })
            .material(.solidColor(0.2, 1, 0.5))
    }
}
