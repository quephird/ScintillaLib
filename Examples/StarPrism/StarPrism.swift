//
//  StarPrism.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct StarPrism: ScintillaApp {
    var camera = Camera(width: 400,
                        height: 400,
                        viewAngle: PI/3,
                        from: Point(0, 5, -5),
                        to: Point(0, 1, 0),
                        up: Vector(0, 1, 0))

    var world = World {
        PointLight(position: Point(-5, 5, -5))
        Prism(bottomY: 0.0,
              topY: 2.0,
              xzPoints: [
                (1.0, 0.0),
                (1.5, 0.5),
                (0.5, 0.5),
                (0.0, 1.0),
                (-0.5, 0.5),
                (-1.5, 0.5),
                (-1.0, 0.0),
                (-1.0, -1.0),
                (0.0, -0.5),
                (1.0, -1.0)])
            .material(.solidColor(1, 0.5, 0))
        Plane()
            .material(.solidColor(1, 1, 1))
    }
}
