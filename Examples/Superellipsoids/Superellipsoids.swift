//
//  Superellipsoids.swift
//  
//
//  Created by Danielle Kefford on 10/1/23.
//

import ScintillaLib

@main
struct Superellipsoids: ScintillaApp {
    var camera = Camera(width: 400,
                        height: 400,
                        viewAngle: PI/3,
                        from: Point(0, 0, -12),
                        to: Point(0, 0, 0),
                        up: Vector(0, 1, 0))

    var world: World = World {
        PointLight(position: Point(0, 5, -5))
        for (i, e) in [0.25, 0.5, 1.0, 2.0, 2.5].enumerated() {
            for (j, n) in [0.25, 0.5, 1.0, 2.0, 2.5].enumerated() {
                Superellipsoid(e: e, n: n)
                    .material(.solidColor((Double(i)+1.0)/5.0, (Double(j)+1.0)/5.0, 0.2))
                    .translate(2.5*(Double(i)-2.0), 2.5*(Double(j)-2.0), 0.0)
            }
        }
    }
}
