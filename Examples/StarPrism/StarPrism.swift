//
//  StarPrism.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct StarPrism: ScintillaApp {
    var body: World {
        PointLight(Point(-5, 5, -5))
        Camera(400, 400, PI/3, .view(
            Point(0, 5, -5),
            Point(0, 1, 0),
            Vector(0, 1, 0)))
        Prism(
            0.0, 2.0,
            [(1.0, 0.0), (1.5, 0.5), (0.5, 0.5), (0.0, 1.0), (-0.5, 0.5),
             (-1.5, 0.5), (-1.0, 0.0), (-1.0, -1.0), (0.0, -0.5), (1.0, -1.0)]
        )
            .material(.solidColor(1, 0.5, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
    }
}
