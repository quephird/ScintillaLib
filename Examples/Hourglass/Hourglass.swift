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
        Camera(width: 400,
               height: 400,
               viewAngle: PI/3,
               from: Point(0, 1, -5),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        ParametricSurface(bottomFrontLeft: (-1.0, -1.0, -1.0),
                          topBackRight: (1.0, 1.0, 1.0),
                          uRange: (0, 2*PI),
                          vRange: (0, 2*PI),
                          accuracy: 0.001,
                          maxGradient: 1.0,
                          fx: { (u, v) in cos(u)*sin(2*v) },
                          fy: { (u, v) in sin(v) },
                          fz: { (u, v) in sin(u)*sin(2*v) })
            .material(.solidColor(0.9, 0.5, 0.5, .hsl))
        Plane()
            .material(.solidColor(1, 1, 1))
            .translate(0, -1.0, 0)
    }
}
