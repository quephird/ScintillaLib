//
//  HollowedSphere.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct HollowedSphere: ScintillaApp {
    var world = World {
        PointLight(Point(-10, 10, -10))
        Camera(400, 400, PI/3, .view(
            Point(0, 1.5, -2),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        Sphere()
            .material(.solidColor(0, 0, 1))
            .intersection {
                Cube()
                    .material(.solidColor(1, 0, 0))
                    .scale(0.8, 0.8, 0.8)
            }
            .difference {
                for (thetaX, thetaZ) in [(0, 0), (0, PI/2), (PI/2, 0)] {
                    Cylinder()
                        .material(.solidColor(0, 1, 0))
                        .scale(0.5, 0.5, 0.5)
                        .rotateX(thetaX)
                        .rotateZ(thetaZ)
                }
            }
            .rotateY(PI/4.0)
    }
}
