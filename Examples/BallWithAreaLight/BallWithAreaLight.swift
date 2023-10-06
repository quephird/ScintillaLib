//
//  BallWithAreaLight.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

//@main
struct BallWithAreaLight: ScintillaApp {
    var body: World {
        AreaLight(
            Point(-5, 5, -5),
            Vector(2, 0, 0), 10,
            Vector(0, 2, 0), 10)
        Camera(400, 400, PI/3, .view(
            Point(0, 2, -5),
            Point(0, 1, 0),
            Vector(0, 1, 0)))
        Sphere()
            .translate(0, 1, 0)
            .material(.solidColor(1, 0, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
    }
}
