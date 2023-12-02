//
//  Rings.swift
//  
//
//  Created by Danielle Kefford on 11/22/23.
//

import Darwin
import ScintillaLib

@main
struct Rings: ScintillaApp {
    var world = World {
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(-10, 7, -10),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-10, 10, -10))
        ParametricSurface(bottomFrontLeft: (-6, -3, -6),
                          topBackRight: (6, 3, 6),
                          uRange: (0, 2*PI),
                          vRange: (0, 2*PI),
                          accuracy: 0.001,
                          maxGradient: 3.0,
                          fx: { (u, v) in (4*(1 + 0.25*sin(3.0*v)) + cos(u))*cos(2.0*v) },
                          fy: { (u, v) in sin(u) + 2.0*cos(3*v) },
                          fz: { (u, v) in (4*(1 + 0.25*sin(3.0*v)) + cos(u))*sin(2.0*v) })
            .material(.solidColor(0.1, 1.0, 0.2))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -3.0, 0)
    }
}
