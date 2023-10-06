//
//  Main.swift
//  
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI
import ScintillaLib

@available(macOS 12.0, *)
@main
struct Main: ScintillaApp {
    @WorldBuilder var world: World {
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

    var body: some Scene {
        WindowGroup {
            ScintillaView(world: world)
                .onDisappear {
                    exit(0)
                }
        }
    }
}
