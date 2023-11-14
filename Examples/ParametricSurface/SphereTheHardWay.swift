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
            (-1.5, -1.5, -1.5), (1.5, 1.5, 1.5),
//            (-3.1, -1, -3.1), (3.1, 7.5, 3.1),
            (-PI, PI), (0, 2*PI),
            // Sphere
            { (u, v) in cos(u)*sin(v) },
            { (u, v) in sin(u)*sin(v) },
            { (u, v) in cos(v) })
            // Ellipsoid
//            { (θ, ϕ) in 3*cos(θ)*sin(ϕ) },
//            { (θ, ϕ) in sin(θ)*sin(ϕ) },
//            { (θ, ϕ) in 2*cos(ϕ) })
            // ???
//            { (u, v) in u },
//            { (u, v) in cos(u)*cos(v) },
//            { (u, v) in cos(u)*sin(v) })
            // Torus
//            { (θ, ϕ) in (2 + cos(ϕ))*cos(θ) },
//            { (θ, ϕ) in (2 + cos(ϕ))*sin(θ) },
//            { (θ, ϕ) in sin(ϕ) })
            // Cylinder
//            { (u, v) in u },
//            { (u, v) in cos(v) },
//            { (u, v) in sin(v) })
            // Steiner surface
//            { (u, v) in 1/2*sin(2*u)*cos(v)*cos(v) },
//            { (u, v) in 1/2*sin(u)*sin(2*v) },
//            { (u, v) in 1/2*cos(u)*sin(2*v) })
            // Spiral
//            { (u, v) in (2.0+cos(v))*cos(u) },
//            { (u, v) in sin(v)+u },
//            { (u, v) in (2.0+cos(v))*sin(u) })
            .material(.solidColor(0.2, 1, 0.5))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -1, 0)
    }
}
