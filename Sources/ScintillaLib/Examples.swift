//
//  Examples.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

func testScene() -> World {
    return World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 10, -15),
            point(0, 0, 0),
            vector(0, 1, 0)))
        for n in 0...3 {
            Cube(.solidColor(Color(1, 0, 0)))
                .rotateY(PI/6)
                .rotateX(PI/6)
                .rotateZ(PI/6)
                .translate(4*cos(Double(n)*PI/2), 0, 4*sin(Double(n)*PI/2))
        }
    }
}

func testGroup() -> World {
    return World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 5, -10),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Group {
            Sphere(.solidColor(Color(1, 0, 0)))
            for n in 0...2 {
                Sphere(.solidColor(Color(0, 1, 0)))
                    .translate(2, 0, 0)
                    .rotateY(2*Double(n)*PI/3)
            }
        }
            .translate(0, 1, 0)
        Plane(.pattern(Checkered2D(.black, .white, .identity)))
    }
}

func testTorus() -> World {
    return World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 5, -10),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Torus(.solidColor(Color(1, 0.5, 0)))
            .translate(0, 1, 0)
        Plane(.pattern(Checkered2D(.black, .white, .identity)))
    }
}

func testDie() -> World {
    let material = Material.solidColor(Color(1, 0.5, 0))
        .reflective(0.2)

    return World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 5, -10),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Cube(material).intersection {
            Sphere(material)
                .scale(1.55, 1.55, 1.55)
            Cylinder(material, -2, 2, true)
                .scale(1.35, 1.35, 1.35)
            Cylinder(material, -2, 2, true)
                .scale(1.35, 1.35, 1.35)
                .rotateX(PI/2)
            Cylinder(material, -2, 2, true)
                .scale(1.35, 1.35, 1.35)
                .rotateZ(PI/2)
        }.difference {
            for (x, y, z) in [
                // face with six dimples
                (-0.6, 1.0, 0.6),
                (-0.6, 1.0, 0.0),
                (-0.6, 1.0, -0.6),
                (0.6, 1.0, 0.6),
                (0.6, 1.0, 0.0),
                (0.6, 1.0, -0.6),
                // face with five dimples
                (0.0, 0.0, -1.0),
                (0.6, 0.6, -1.0),
                (0.6, -0.6, -1.0),
                (-0.6, 0.6, -1.0),
                (-0.6, -0.6, -1.0),
                // face with four dimples
                (1.0, 0.6, 0.6),
                (1.0, 0.6, -0.6),
                (1.0, -0.6, 0.6),
                (1.0, -0.6, -0.6),
                // face with three dimples
                (-1.0, 0.6, 0.6),
                (-1.0, 0, 0),
                (-1.0, -0.6, -0.6),
                // face with two dimples
                (0.6, 0.6, 1.0),
                (-0.6, -0.6, 1.0),
                // face with one dimple
                (0.0, -1.0, 0.0),
            ] {
                Sphere(.solidColor(Color(1, 1, 1)))
                    .scale(0.2, 0.2, 0.2)
                    .translate(x, y, z)
            }
        }
            .rotateY(PI/3)
            .translate(0.0, 1.0, 0.0)
        Plane(.pattern(Checkered2D(.black, .white, .identity)))
    }
}

func chapterSevenScene() -> World {
    return World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 2, -5),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Sphere(.solidColor(Color(1, 0.9, 0.9)))
            .scale(10, 0.01, 10)
        Sphere(.solidColor(Color(1, 0.9, 0.9)))
            .scale(10, 0.01, 10)
            .rotateX(PI/2)
            .rotateY(-PI/4)
            .translate(0, 0, 5)
        Sphere(.solidColor(Color(1, 0.9, 0.9)))
            .scale(10, 0.01, 10)
            .rotateX(PI/2)
            .rotateY(PI/4)
            .translate(0, 0, 5)
        Sphere(.solidColor(Color(1, 0.8, 0.1))
                .diffuse(0.7)
                .specular(0.3))
            .scale(0.33, 0.33, 0.33)
            .translate(-1.5, 0.33, -0.75)
        Sphere(.solidColor(Color(0.1, 1.0, 0.5))
                .diffuse(0.7)
                .specular(0.3))
            .translate(-0.5, 1.0, 0.5)
        Sphere(.solidColor(Color(0.5, 1, 0.1))
                .diffuse(0.7)
                .specular(0.3))
            .scale(0.5, 0.5, 0.5)
            .translate(1.5, 0.5, -0.5)
    }
}

//func chapterNineScene() -> World {
//    let floorMaterial = Material(.solidColor(Color(1, 0.9, 0.9)), 0.1, 0.9, 0.0, 200, 0.0, 0.0, 0.0)
//    let floor = Plane(.identity, floorMaterial)
//
//    let leftBallTransform = translation(-1.5, 0.33, -0.75)
//        .multiplyMatrix(scaling(0.33, 0.33, 0.33))
//    let leftBallMaterial = Material(.solidColor(Color(1, 0.8, 0.1)), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let leftBall = Sphere(leftBallTransform, leftBallMaterial)
//
//
//    let middleBallTransform = translation(-0.5, 1, 0.5)
//    let middleBallMaterial = Material(.solidColor(Color(0.1, 1, 0.5)), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let middleBall = Sphere(middleBallTransform, middleBallMaterial)
//
//
//    let rightBallTransform = translation(1.5, 0.5, -0.5)
//        .multiplyMatrix(scaling(0.5, 0.5, 0.5))
//    let rightBallMaterial = Material(.solidColor(Color(0.5, 1, 0.1)), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let rightBall = Sphere(rightBallTransform, rightBallMaterial)
//
//    let light = Light(point(-10, 10, -10), Color(1, 1, 1))
//    let objects = [floor, leftBall, middleBall, rightBall]
//
//    return World(light, objects)
//}
//
//func chapterTenScene() -> World {
//    let floorPattern = Checkered2D(.black, .white, rotationY(PI/6))
//    let floorMaterial = Material(.pattern(floorPattern), 0.1, 0.9, 0.0, 200, 0.0, 0.0, 0.0)
//    let floor = Plane(.identity, floorMaterial)
//
//    let leftBallTransform = translation(-1.5, 0.33, -0.75)
//        .multiplyMatrix(scaling(0.33, 0.33, 0.33))
//    let leftBallMaterial = Material(.solidColor(Color(1, 0.8, 0.1)), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let leftBall = Sphere(leftBallTransform, leftBallMaterial)
//
//
//    let middleBallTransform = translation(-0.5, 1, 0.5)
//    let middleBallPattern = Checkered3D(
//        Color(0.2, 0.6, 0.4),
//        Color(0.8, 0.1, 0.4),
//        scaling(0.25, 0.25, 0.25).multiplyMatrix(rotationY(PI/6)))
//    let middleBallMaterial = Material(.pattern(middleBallPattern), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let middleBall = Sphere(middleBallTransform, middleBallMaterial)
//
//
//    let gradientTransform = translation(-1, 0, 0).multiplyMatrix(scaling(2, 1, 1))
//    let gradient = Gradient(Color(0.5, 1, 0.1), Color(0.9, 0.2, 0.4), gradientTransform)
//    let rightBallTransform = translation(1.5, 0.5, -0.5)
//        .multiplyMatrix(scaling(0.5, 0.5, 0.5))
//    let rightBallMaterial = Material(.pattern(gradient), 0.1, 0.7, 0.3, 200, 0.0, 0.0, 0.0)
//    let rightBall = Sphere(rightBallTransform, rightBallMaterial)
//
//    let light = Light(point(-10, 10, -10), Color(1, 1, 1))
//    let objects = [floor, leftBall, middleBall, rightBall]
//
//    return World(light, objects)
//}
//
//func chapterThirteenScene() -> World {
//    let floorPattern = Checkered2D(.black, .white, rotationY(PI/3))
//    let floorMaterial = Material(.pattern(floorPattern), 0.1, 0.9, 0.0, 200, 0.0, 0.0, 0.0)
//    let floor = Plane(.identity, floorMaterial)
//
//    let gradientTransform = scaling(1, 2.01, 1).multiplyMatrix(rotationZ(PI/2))
//    let gradient = Gradient(Color(0.9, 1.0, 0.0), Color(0.1, 0.2, 0.8), gradientTransform)
//    let cylinderMaterial = Material(.pattern(gradient), 0.5, 0.9, 0.9, 200.0, 0.1, 0.0, 1.0)
//    let cylinder = Cylinder(translation(-2, 0, 0), cylinderMaterial, 0, 2, true)
//
//    let checkered = Checkered3D(.white, Color(1, 0, 0), scaling(0.25, 0.25, 0.25))
//    let coneMaterial = Material(.pattern(checkered), 0.5, 0.9, 0.9, 200, 0.1, 0.0, 1.0)
//    let coneTransform = translation(2, 2, 0).multiplyMatrix(scaling(1, 2, 1))
//    let cone = Cone(coneTransform, coneMaterial, -1, 0, true)
//
//    let light = Light(point(-10, 10, -10), Color(1, 1, 1))
//    let objects = [floor, cylinder, cone]
//
//    return World(light, objects)
//}
//
//func chapterFourteenScene() -> World {
//    let hexagonTransform = translation(0, 1.5, 0)
//        .multiplyMatrix(rotationX(-PI/6))
//    let hexagon = Group(hexagonTransform, DEFAULT_MATERIAL)
//    for n in 0...5 {
//        let cornerTransform = translation(0, 0, -1)
//            .multiplyMatrix(scaling(0.25, 0.25, 0.25))
//        let corner = Sphere(cornerTransform, DEFAULT_MATERIAL)
//
//        let edgeTransform = translation(0, 0, -1)
//            .multiplyMatrix(rotationY(-PI/6))
//            .multiplyMatrix(rotationZ(-PI/2))
//            .multiplyMatrix(scaling(0.25, 1, 0.25))
//        let edge = Cylinder(edgeTransform, DEFAULT_MATERIAL, 0, 1)
//
//        let sideTransform = rotationY(Double(n)*PI/3)
//        let side = Group(sideTransform, DEFAULT_MATERIAL)
//        side.addChild(corner)
//        side.addChild(edge)
//
//        hexagon.addChild(side)
//    }
//
//    let light = Light(point(-10, 10, -10), Color(1, 1, 1))
//    let objects = [hexagon]
//
//    return World(light, objects)
//}
//
//func makeDie(_ color: Color, _ transform: Matrix4) -> Shape {
//    let roundingRadius = 0.125
//    var dieMaterial = DEFAULT_MATERIAL
//    dieMaterial.colorStrategy = .solidColor(color)
//    dieMaterial.reflective = 0.2
//    let dieBody = Group(.identity, dieMaterial)
//
//    for z in 0...1 {
//        for y in 0...1 {
//            for x in 0...1 {
//                let transform = translation(Double(x)-0.5, Double(y)-0.5, Double(z)-0.5)
//                    .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//                let corner = Sphere(transform, dieMaterial)
//                dieBody.addChild(corner)
//            }
//        }
//    }
//
//    for z in 0...1 {
//        for x in 0...1 {
//            let transform = translation(Double(x)-0.5, 0, Double(z)-0.5)
//                .multiplyMatrix(scaling(roundingRadius, 1, roundingRadius))
//            let edge = Cylinder(transform, dieMaterial, -0.5, 0.5)
//            dieBody.addChild(edge)
//        }
//    }
//
//    for y in 0...1 {
//        for z in 0...1 {
//            let transform = translation(0, Double(y)-0.5, Double(z)-0.5)
//                .multiplyMatrix(rotationZ(PI/2))
//                .multiplyMatrix(scaling(roundingRadius, 1, roundingRadius))
//            let edge = Cylinder(transform, dieMaterial, -0.5, 0.5)
//            dieBody.addChild(edge)
//        }
//    }
//
//    for y in 0...1 {
//        for x in 0...1 {
//            let transform = translation(Double(x)-0.5, Double(y)-0.5, 0)
//                .multiplyMatrix(rotationX(PI/2))
//                .multiplyMatrix(scaling(roundingRadius, 1, roundingRadius))
//            let edge = Cylinder(transform, dieMaterial, -0.5, 0.5)
//            dieBody.addChild(edge)
//        }
//    }
//
//    for x in 0...1 {
//        let transform = translation(Double(x)-0.5, 0, 0)
//            .multiplyMatrix(scaling(roundingRadius, 0.5, 0.5))
//        let side = Cube(transform, dieMaterial)
//        dieBody.addChild(side)
//    }
//
//    for y in 0...1 {
//        let transform = translation(0, Double(y)-0.5, 0)
//            .multiplyMatrix(scaling(0.5, roundingRadius, 0.5))
//        let side = Cube(transform, dieMaterial)
//        dieBody.addChild(side)
//    }
//
//    for z in 0...1 {
//        let transform = translation(0, 0, Double(z)-0.5)
//            .multiplyMatrix(scaling(0.5, 0.5, roundingRadius))
//        let side = Cube(transform, dieMaterial)
//        dieBody.addChild(side)
//    }
//
//    var pitMaterial = DEFAULT_MATERIAL
//    pitMaterial.colorStrategy = .solidColor(.white)
//
//    let pitTransform = translation(0, 0, -roundingRadius-0.5)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit = Sphere(pitTransform, pitMaterial)
//
//    let pitTransform21 = translation(roundingRadius+0.5, -0.3, -0.3)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit21 = Sphere(pitTransform21, pitMaterial)
//    let pitTransform22 = translation(roundingRadius+0.5, 0.3, 0.3)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit22 = Sphere(pitTransform22, pitMaterial)
//
//    let pitTransform31 = translation(-0.3, roundingRadius+0.5, -0.3)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit31 = Sphere(pitTransform31, pitMaterial)
//    let pitTransform32 = translation(0, roundingRadius+0.5, 0)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit32 = Sphere(pitTransform32, pitMaterial)
//    let pitTransform33 = translation(0.3, roundingRadius+0.5, 0.3)
//        .multiplyMatrix(scaling(roundingRadius, roundingRadius, roundingRadius))
//    let pit33 = Sphere(pitTransform33, pitMaterial)
//
//    var die = CSG(.difference, dieBody, pit)
//    die = CSG(.difference, die, pit21)
//    die = CSG(.difference, die, pit22)
//    die = CSG(.difference, die, pit31)
//    die = CSG(.difference, die, pit32)
//    die = CSG(.difference, die, pit33)
//    die.transform = transform
//    return die
//}
//
//func chapterSixteenScene() -> World {
//    let floorPattern = Checkered2D(Color(0.1, 0.1, 0.1), .white, rotationY(PI/3))
//    let floorMaterial = Material(.pattern(floorPattern), 0.1, 0.9, 0.0, 200, 0.4, 0.0, 0.0)
//    let floor = Plane(translation(0, -0.625, 0), floorMaterial)
//
//    let leftTransform = translation(-1.5, 0, 0).multiplyMatrix(rotationY(PI/4))
//    let leftDie = makeDie(Color(0.8, 0.4, 0.8), leftTransform)
//
//    let rightTransform = translation(1.5, 0, 0).multiplyMatrix(rotationY(PI/3))
//    let rightDie = makeDie(Color(0.8, 0.4, 0.1), rightTransform)
//
//    let light = Light(point(-10, 10, -10), Color(1, 1, 1))
//    let objects = [floor, leftDie, rightDie]
//
//    return World(light, objects)
//}
