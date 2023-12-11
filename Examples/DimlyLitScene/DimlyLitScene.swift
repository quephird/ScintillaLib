//
//  DimlyLitScene.swift
//
//
//  Created by Danielle Kefford on 11/28/23.
//

import ScintillaLib

@main
struct DimlyLitScene: ScintillaApp {
    var camera = Camera(width: 400,
                        height: 400,
                        viewAngle: PI/3,
                        from: Point(0, 0, -5),
                        to: Point(0, 0, 0),
                        up: Vector(0, 1, 0))

    var world = World {

        PointLight(position: Point(-10, 10, 0),
                   fadeDistance: 10)
        Sphere()
            .material(.solidColor(1, 0.5, 0))
        Plane()
            .translate(0, -1, 0)
    }
}
