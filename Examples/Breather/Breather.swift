//
//  Breather.swift
//  
//
//  Created by Danielle Kefford on 11/18/23.
//

import Darwin
import ScintillaLib

func d(u: Double, v: Double) -> Double {
    return 0.4*(0.84*pow(cosh(0.4*u), 2) + 0.16*pow(sin(sqrt(0.84)*v), 2))
}
func x(u: Double, v: Double) -> Double {
    return -u + 2*0.84*cosh(0.4*u)*sinh(0.4*u)/d(u: u, v: v)
}
func y(u: Double, v: Double) -> Double {
    return 2*sqrt(0.84)*cosh(0.4*u)*(-sqrt(0.84)*cos(v)*cos(sqrt(0.84)*v) - sin(v)*sin(sqrt(0.84)*v))/d(u: u, v: v)
}
func z(u: Double, v: Double) -> Double {
    return 2*sqrt(0.84)*cosh(0.4*u)*(-sqrt(0.84)*sin(v)*cos(sqrt(0.84)*v) + cos(v)*sin(sqrt(0.84)*v))/d(u: u, v: v)
}

// ACHTUNG: This takes a _long_ time to render!
@available(macOS 12.0, *)
@main
struct Breather: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 0, -15),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        ParametricSurface(
            (-8, -5, -5), (8, 5, 5),
            (-15, 15), (-38, 38),
            0.05, 5.0,
            { (u, v) in x(u: u, v: v) },
            { (u, v) in y(u: u, v: v) },
            { (u, v) in z(u: u, v: v) })
            .material(.solidColor(0.1, 0.2, 1.0))
            .rotateY(PI/8.0)
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -5.5, 0)
    }
}
