//
//  WorldTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest

let testCamera = Camera(800, 600, PI/3, .view(
    point(0, 1, -1),
    point(0, 0, 0),
    vector(0, 1, 0)))

func testWorld() -> World {
    World {
        Light(point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            point(0, 1, -1),
            point(0, 0, 0),
            vector(0, 1, 0)))
        Sphere(.solidColor(Color(0.8, 1.0, 0.6))
            .ambient(0.1)
            .diffuse(0.7)
            .specular(0.2)
            .refractive(0.0)
        )
        Sphere(.basicMaterial())
            .scale(0.5, 0.5, 0.5)
    }
}

class WorldTests: XCTestCase {
    func testIntersect() throws {
        let world = testWorld()
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let intersections = world.intersect(ray)
        XCTAssertEqual(intersections.count, 4)
        XCTAssert(intersections[0].t.isAlmostEqual(4))
        XCTAssert(intersections[1].t.isAlmostEqual(4.5))
        XCTAssert(intersections[2].t.isAlmostEqual(5.5))
        XCTAssert(intersections[3].t.isAlmostEqual(6))
    }

    func testShadeHit() throws {
        let world = testWorld()
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let shape = world.objects[0]
        let intersection = Intersection(4, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.38066, 0.47583, 0.28549)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitInside() throws {
        var world = testWorld()
        let light = Light(point(0, 0.25, 0), Color(1, 1, 1))
        world.light = light
        let ray = Ray(point(0, 0, 0), vector(0, 0, 1))
        let shape = world.objects[1]
        let intersection = Intersection(0.5, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.90498, 0.90498, 0.90498)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitIntersectionInShadow() throws {
        let s1 = Sphere(.basicMaterial())
        let s2 = Sphere(.basicMaterial())
            .translate(0, 0, 10)
        let world = World {
            Light(point(0, 0, -10), Color(1, 1, 1))
            Camera(800, 600, PI/3, .view(
                point(0, 1, -1),
                point(0, 0, 0),
                vector(0, 1, 0)))
            s1
            s2
        }

        let ray = Ray(point(0, 0, 5), vector(0, 0, 1))
        let intersection = Intersection(4, s2)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtMiss() throws {
        let world = testWorld()
        let ray = Ray(point(0, 0, -5), vector(0, 1, 0))
        let actualValue = world.colorAt(ray, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtHit() throws {
        let world = testWorld()
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let actualValue = world.colorAt(ray, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.38066, 0.47583, 0.2855)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

//    func testColorAtIntersectionBehindRay() throws {
//        let world = testWorld()
//        let outerSphere = world.objects[0]
//        outerSphere.material.ambient = 1.0
//        let innerSphere = world.objects[1]
//        innerSphere.material.ambient = 1.0
//
//        let ray = Ray(point(0, 0, 0.75), vector(0, 0, -1))
//        let actualValue = world.colorAt(ray, MAX_RECURSIVE_CALLS)
//        let expectedValue = Color(0.8, 1.0, 0.6)
//        XCTAssert(actualValue.isAlmostEqual(expectedValue))
//    }

    func testIsShadowedPointAndLightNotCollinear() throws {
        let world = testWorld()
        let point = point(0, 10, 0)
        XCTAssertFalse(world.isShadowed(point))
    }

    func testIsShadowedObjectBetweenPointAndLight() throws {
        let world = testWorld()
        let point = point(10, -10, 10)
        XCTAssertTrue(world.isShadowed(point))
    }

    func testIsShadowedObjectBehindLight() throws {
        let world = testWorld()
        let point = point(-20, 20, -20)
        XCTAssertFalse(world.isShadowed(point))
    }

    func testIsShadowedObjectBehindPoint() throws {
        let world = testWorld()
        let point = point(-2, 2, -2)
        XCTAssertFalse(world.isShadowed(point))
    }

    func testReflectedColorForNonreflectiveMaterial() {
        let world = testWorld()
        let secondShape = world.objects[1]
        secondShape.material.ambient = 1

        let ray = Ray(point(0, 0, 0), vector(0, 0, 1))
        let intersection = Intersection(1, secondShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.reflectedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveMaterial() throws {
        var world = testWorld()
        let anotherShape = Plane(.basicMaterial()
            .reflective(0.5))
            .translate(0, -1, 0)
        world.objects.append(anotherShape)

        let ray = Ray(point(0, 0, -3), vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), anotherShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.87676, 0.92434, 0.82917)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtTerminatesForWorldWithMutuallyReflectiveSurfaces() throws {
        let world = World {
            Light(point(0, 0, 0))
            Camera(800, 600, PI/3, .view(
                point(0, 1, -1),
                point(0, 0, 0),
                vector(0, 1, 0)))
            Plane(.basicMaterial().reflective(1.0))
                .translate(0, -1, 0)
            Plane(.basicMaterial().reflective(1.0))
                .translate(0, 1, 0)
        }
        let ray = Ray(point(0, 0, 0), vector(0, 1, 0))
        // The following call should terminate; no need to test return value
        let _ = world.colorAt(ray, MAX_RECURSIVE_CALLS)
    }

    func testColorAtMaxRecursiveDepth() throws {
        var world = testWorld()
        let additionalShape = Plane(Material.basicMaterial()
            .reflective(0.5))
            .translate(0, -1, 0)
        world.objects.append(additionalShape)

        let ray = Ray(point(0, 0, -3), vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), additionalShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.reflectedColorAt(computations, 0)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorWithOpaqueSurface() throws {
        let world = testWorld()
        let firstShape = world.objects[0]
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let allIntersections = [
            Intersection(4, firstShape),
            Intersection(6, firstShape),
        ]
        let computations = allIntersections[0].prepareComputations(ray, allIntersections)
        let actualValue = world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorAtMaximumRecursiveDepth() throws {
        let world = testWorld()
        let firstShape = world.objects[0]
        let material = Material.basicMaterial()
        material.transparency = 1.0
        material.refractive = 1.5
        firstShape.material = material
        let ray = Ray(point(0, 0, -5), vector(0, 0, 1))
        let allIntersections = [
            Intersection(4, firstShape),
            Intersection(6, firstShape),
        ]
        let computations = allIntersections[0].prepareComputations(ray, allIntersections)
        let actualValue = world.refractedColorAt(computations, 0)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorUnderTotalInternalReflection() throws {
        let world = testWorld()
        let firstShape = world.objects[0]
        let material = Material.basicMaterial()
        material.transparency = 1.0
        material.refractive = 1.5
        firstShape.material = material
        let ray = Ray(point(0, 0, sqrt(2)/2), vector(0, 1, 0))
        let allIntersections = [
            Intersection(-sqrt(2)/2, firstShape),
            Intersection(sqrt(2)/2, firstShape),
        ]
        let computations = allIntersections[1].prepareComputations(ray, allIntersections)
        let actualValue = world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorWithRefractedRay() throws {
        class Test: Pattern {
            override init(_ transform: Matrix4) {
                super.init(transform)
            }

            override func colorAt(_ patternPoint: Tuple4) -> Color {
                return Color(patternPoint[0], patternPoint[1], patternPoint[2])
            }
        }

        let world = testWorld()
        let shapeA = world.objects[0]
        let materialA = Material.basicMaterial()
        materialA.colorStrategy = .pattern(Test(.identity))
        materialA.ambient = 1.0
        shapeA.material = materialA

        let shapeB = world.objects[1]
        let materialB = Material.basicMaterial()
        materialB.transparency = 1.0
        materialB.refractive = 1.5
        shapeB.material = materialB

        let ray = Ray(point(0, 0, 0.1), vector(0, 1, 0))
        let allIntersections = [
            Intersection(-0.9899, shapeA),
            Intersection(-0.4899, shapeB),
            Intersection(0.4899, shapeB),
            Intersection(0.9899, shapeA),
        ]
        let computations = allIntersections[2].prepareComputations(ray, allIntersections)
        let actualValue = world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0.99888, 0.04722)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithTransparentMaterial() throws {
        var world = testWorld()
        let floor = Plane(Material.basicMaterial()
            .transparency(0.5)
            .refractive(1.5))
            .translate(0, -1, 0)
        let ball = Sphere(Material(.solidColor(Color(1, 0, 0)))
            .ambient(0.5))
            .translate(0, -3.5, -0.5)
        world.objects.append(contentsOf: [floor, ball])

        let ray = Ray(point(0, 0, -3), vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), floor)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93642, 0.68642, 0.68642)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForTotalInternalReflection() throws {
        let glass = Material(.solidColor(.white), 0.1, 0.9, 0.9, 200, 0.0, 1.0, 1.5)
        let glassySphere = Sphere(glass)
        let world = World {
            Light(point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                point(0, 1, -1),
                point(0, 0, 0),
                vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(point(0, 0, sqrt(2)/2), vector(0, 1, 0))
        let allIntersections = [
            Intersection(-sqrt(2)/2, glassySphere),
            Intersection(sqrt(2)/2, glassySphere),
        ]
        let computations = allIntersections[1].prepareComputations(ray, allIntersections)
        let actualValue = world.schlickReflectance(computations)
        let expectedValue = 1.0
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForPerpendicularRay() throws {
        let glass = Material(.solidColor(.white), 0.1, 0.9, 0.9, 200, 0.0, 1.0, 1.5)
        let glassySphere = Sphere(glass)
        let world = World {
            Light(point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                point(0, 1, -1),
                point(0, 0, 0),
                vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(point(0, 0, 0), vector(0, 1, 0))
        let allIntersections = [
            Intersection(-1, glassySphere),
            Intersection(1, glassySphere),
        ]
        let computations = allIntersections[1].prepareComputations(ray, allIntersections)
        let actualValue = world.schlickReflectance(computations)
        let expectedValue = 0.04
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForSmallAngleAndN2GreaterThanN1() throws {
        let glass = Material(.solidColor(.white), 0.1, 0.9, 0.9, 200, 0.0, 1.0, 1.5)
        let glassySphere = Sphere(glass)
        let world = World {
            Light(point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                point(0, 1, -1),
                point(0, 0, 0),
                vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(point(0, 0.99, -2), vector(0, 0, 1))
        let intersection = Intersection(1.8589, glassySphere)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.schlickReflectance(computations)
        let expectedValue = 0.48873
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveAndTransparentMaterial() throws {
        var world = testWorld()
        let floor = Plane(Material.basicMaterial()
            .transparency(0.5)
            .reflective(0.5)
            .refractive(1.5))
            .translate(0, -1, 0)

        let ball = Sphere(Material(.solidColor(Color(1, 0, 0)))
            .ambient(0.5))
            .translate(0, -3.5, -0.5)

        world.objects.append(contentsOf: [floor, ball])

        let ray = Ray(point(0, 0, -3), vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), floor)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93391, 0.69643, 0.69243)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRayForPixelForCenterOfCanvas() throws {
        let light = Light(point(-10, 10, -10))
        let camera = Camera(201, 101, PI/2, .identity)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(vector(0, 0, -1)))
    }

    func testRayForPixelForCornerOfCanvas() throws {
        let light = Light(point(-10, 10, -10))
        let camera = Camera(201, 101, PI/2, .identity)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(0, 0)
        XCTAssert(ray.origin.isAlmostEqual(point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(vector(0.66519, 0.33259, -0.66851)))
    }

    func testRayForPixelForTransformedCamera() throws {
        let light = Light(point(-10, 10, -10))
        let transform = Matrix4.rotationY(PI/4)
            .multiplyMatrix(.translation(0, -2, 5))
        let camera = Camera(201, 101, PI/2, transform)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(point(0, 2, -5)))
        XCTAssert(ray.direction.isAlmostEqual(vector(sqrt(2)/2, 0, -sqrt(2)/2)))
    }
}
