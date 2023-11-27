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
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 7, -15),
               to: Point(0, 7, 0),
               up: Vector(0, 1, 0))
        ParametricSurface(bottomFrontLeft: (-3.5, 0, -3.5),
                          topBackRight: (3.5, 15.0, 3.5),
                          uRange: (0, 2*PI),
                          vRange: (0, 7*PI),
                          accuracy: 0.001,
                          maxGradient: 1.0,
                          fx: { (u, v) in (2 + cos(u) + 0.1*cos(8*u))*cos(v) },
                          fy: { (u, v) in 2 + sin(u) + 0.1*sin(8*u) + 0.5*v },
                          fz: { (u, v) in (2 + cos(u) + 0.1*cos(8*u))*sin(v) })
            .material(.solidColor(1.0, 0.8, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -3.0, 0)
    }
}
