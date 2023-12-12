//
//  HollowedSphere.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct HollowedSphere: ScintillaApp {
    var camera = Camera(width: 400,
                        height: 400,
                        viewAngle: PI/3,
                        from: Point(0, 1.5, -2),
                        to: Point(0, 0, 0),
                        up: Vector(0, 1, 0))

    var world = World {
        PointLight(position: Point(-10, 10, -10))
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
