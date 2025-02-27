//
//  Wine.swift
//
//
//  Created by Danielle Kefford on 11/30/23.
//

import ScintillaLib

@available(macOS 12.0, *)
@main
struct Wine: ScintillaApp {
    var world = World {
        let bottleGreen: any Material = .uniform(0.0, 0.2, 0.0)
            .transparency(1.0)
            .shininess(1.0)
            .refractive(1.5)
        let wineRed: any Material = .uniform(0.2, 0.0, 0.0)
            .ambient(1.0)
            .specular(0.0)
            .transparency(0.5)
            .shininess(1.0)
        let wineGlass: any Material = .uniform(0.0, 0.0, 0.0)
            .shininess(1.0)
            .transparency(1.0)
            .reflective(1.0)
            .refractive(1.5)

        Camera(width: 600,
               height: 600,
               viewAngle: PI/3,
               from: Point(0, 3, -10),
               to: Point(0, 3, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-10, 10, -10))
        Plane()
            .material(.uniform(1.0, 1.0, 1.0)
                .shininess(1.0))
        Group {
            Group {
                Cylinder(bottomY: 0.0, // Bottle body
                         topY: 5.0,
                         isCapped: true)
                    .material(bottleGreen)
                Sphere() // Transition to neck
                    .material(bottleGreen)
                    .scale(1.0, 0.6, 1.0)
                    .translate(0.0, 5.0, 0.0)
                Cylinder(bottomY: 5.6, // Neck
                         topY: 7.0,
                         isCapped: true)
                    .material(bottleGreen)
                    .scale(0.4, 1.0, 0.4)
            }
            .difference { // Hollow out bottle
                Cylinder(bottomY: 0.05,
                         topY: 4.95,
                         isCapped: true)
                    .material(bottleGreen)
                Sphere()
                    .material(bottleGreen)
                    .scale(0.95, 0.55, 0.95)
                    .translate(0.0, 5.0, 0.0)
                Cylinder(bottomY: 5.6,
                         topY: 7.0,
                         isCapped: true)
                    .material(bottleGreen)
                    .scale(0.35, 1.0, 0.35)
            }
            Cylinder(bottomY: 0.04, // Wine in bottle
                     topY: 2.0,
                     isCapped: true)
                .material(wineRed)
                .scale(0.94, 0.94, 0.94)
        }
            .translate(-2, 0, 0)
        Group {
            Sphere() // Wine glass base
                .material(wineGlass)
                .scale(1.0, 0.2, 1.0)
            Cylinder(bottomY: 0.05, topY: 1.5, isCapped: true) // Stem
                .material(wineGlass)
                .scale(0.15, 1.0, 0.15)
            SurfaceOfRevolution(yzPoints: [(1.5, 0.2), // Body
                                           (2.0, 1.0),
                                           (3.5, 0.9)])
                .material(wineGlass)
            SurfaceOfRevolution(yzPoints: [(1.55, 0.15), // Wine in glass
                                           (2.0, 0.95),
                                           (2.5, 0.85)])
                .material(wineRed)
        }
            .translate(1.0, 0.0, 0.0)
        Cylinder(bottomY: 0.0, topY: 0.8, isCapped: true) // Cork
            .material(.uniform(0.8, 0.7, 0.6))
            .scale(0.25, 1.0, 0.25)
            .rotateX(PI/2)
            .rotateY(PI/3)
            .translate(-0.5, 0.25, -2.5)
    }
}
