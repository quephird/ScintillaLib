//
//  WorldTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@testable import ScintillaLib

let testCamera = Camera(800, 600, PI/3, .view(
    Point(0, 1, -1),
    Point(0, 0, 0),
    Vector(0, 1, 0)))

func testWorld() -> World {
    World {
        PointLight(Point(-10, 10, -10))
        Camera(800, 600, PI/3, .view(
            Point(0, 1, -1),
            Point(0, 0, 0),
            Vector(0, 1, 0)))
        Sphere()
            .material(SolidColor(0.8, 1.0, 0.6)
                .ambient(0.1)
                .diffuse(0.7)
                .specular(0.2)
                .refractive(0.0))
        Sphere()
            .scale(0.5, 0.5, 0.5)
    }
}

class WorldTests: XCTestCase {
    func testIntersect() throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let intersections = world.intersect(ray)
        XCTAssertEqual(intersections.count, 4)
        XCTAssert(intersections[0].t.isAlmostEqual(4))
        XCTAssert(intersections[1].t.isAlmostEqual(4.5))
        XCTAssert(intersections[2].t.isAlmostEqual(5.5))
        XCTAssert(intersections[3].t.isAlmostEqual(6))
    }

    func testShadeHit() throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let shape = world.objects[0]
        let intersection = Intersection(4, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.38066, 0.47583, 0.28549)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitInside() throws {
        let world = testWorld()
        let light = PointLight(Point(0, 0.25, 0), Color(1, 1, 1))
        world.light = light
        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let shape = world.objects[1]
        let intersection = Intersection(0.5, shape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.90498, 0.90498, 0.90498)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitIntersectionInShadow() throws {
        let s1 = Sphere()
        let s2 = Sphere()
            .translate(0, 0, 10)
        let world = World {
            PointLight(Point(0, 0, -10), Color(1, 1, 1))
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            s1
            s2
        }

        let ray = Ray(Point(0, 0, 5), Vector(0, 0, 1))
        let intersection = Intersection(4, s2)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtMiss() throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 1, 0))
        let actualValue = world.colorAt(ray, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtHit() throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
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
        let worldPoint = Point(0, 10, 0)
        XCTAssertFalse(world.isShadowed(world.light.position, worldPoint))
    }

    func testIsShadowedObjectBetweenPointAndLight() throws {
        let world = testWorld()
        let worldPoint = Point(10, -10, 10)
        XCTAssertTrue(world.isShadowed(world.light.position, worldPoint))
    }

    func testIsShadowedObjectBehindLight() throws {
        let world = testWorld()
        let worldPoint = Point(-20, 20, -20)
        XCTAssertFalse(world.isShadowed(world.light.position, worldPoint))
    }

    func testIsShadowedObjectBehindPoint() throws {
        let world = testWorld()
        let worldPoint = Point(-2, 2, -2)
        XCTAssertFalse(world.isShadowed(world.light.position, worldPoint))
    }

    func testIntensityOfPointLight() throws {
        let testCases = [
            (Point(0, 1.0001, 0), 1.0),
            (Point(-1.0001, 0, 0), 1.0),
            (Point(0, 0, -1.0001), 1.0),
            (Point(0, 0, 1.0001), 0.0),
            (Point(1.0001, 0, 0), 0.0),
            (Point(0, -1.0001, 0), 0.0),
            (Point(0, 0, 0), 0.0),
        ]

        let world = testWorld()
        let light = world.light

        for (worldPoint, expectedIntensity) in testCases {
            let actualIntesity = world.intensity(light, worldPoint)
            XCTAssertEqual(actualIntesity, expectedIntensity)
        }
    }

    func testIntensityOfAreaLightWithNoJitter() throws {
        let areaLight = AreaLight(
            Point(-0.5, -0.5, -5),
            Color(1, 1, 1),
            Vector(1, 0, 0), 2,
            Vector(0, 1, 0), 2,
            NoJitter())
        let world = World {
            areaLight
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            Sphere()
                .material(SolidColor(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
        }

        let testCases = [
            (Point(0, 0, 2), 0.0),
            (Point(1, -1, 2), 0.25),
            (Point(1.5, 0, 2), 0.5),
            (Point(1.25, 1.25, 3), 0.75),
            (Point(0, 0, -2), 1.0),
        ]
        for (worldPoint, expectedIntensity) in testCases {
            let actualIntensity = world.intensity(areaLight, worldPoint)
            XCTAssertEqual(actualIntensity, expectedIntensity)
        }
    }

    func testIntensityOfAreaLightWithPseduorandomJitter() throws {
        let areaLight = AreaLight(
            Point(-0.5, -0.5, -5),
            Color(1, 1, 1),
            Vector(1, 0, 0), 2,
            Vector(0, 1, 0), 2,
            PseudorandomJitter([0.7, 0.3, 0.9, 0.1, 0.5]))
        let world = World {
            areaLight
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            Sphere()
                .material(SolidColor(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
        }

        let testCases = [
            (Point(0, 0, 2), 0.0),
            (Point(1, -1, 2), 0.5),
            (Point(1.5, 0, 2), 1.0),
            (Point(1.25, 1.25, 3), 0.75),
            (Point(0, 0, -2), 1.0),
        ]
        for (worldPoint, expectedIntensity) in testCases {
            let actualIntensity = world.intensity(areaLight, worldPoint)
            XCTAssertEqual(actualIntensity, expectedIntensity)
            print(actualIntensity)
        }
    }

    func testReflectedColorForNonreflectiveMaterial() {
        let world = testWorld()
        let secondShape = world.objects[1]
        secondShape.material.properties.ambient = 1

        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let intersection = Intersection(1, secondShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.reflectedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveMaterial() throws {
        let world = testWorld()
        let anotherShape = Plane()
            .material(.basicMaterial()
                .reflective(0.5))
            .translate(0, -1, 0)
        world.objects.append(anotherShape)

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), anotherShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.87676, 0.92434, 0.82917)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtTerminatesForWorldWithMutuallyReflectiveSurfaces() throws {
        let world = World {
            PointLight(Point(0, 0, 0))
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            Plane()
                .material(.basicMaterial().reflective(1.0))
                .translate(0, -1, 0)
            Plane()
                .material(.basicMaterial().reflective(1.0))
                .translate(0, 1, 0)
        }
        let ray = Ray(Point(0, 0, 0), Vector(0, 1, 0))
        // The following call should terminate; no need to test return value
        let _ = world.colorAt(ray, MAX_RECURSIVE_CALLS)
    }

    func testColorAtMaxRecursiveDepth() throws {
        let world = testWorld()
        let additionalShape = Plane()
            .material(.basicMaterial().reflective(0.5))
            .translate(0, -1, 0)
        world.objects.append(additionalShape)

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), additionalShape)
        let computations = intersection.prepareComputations(ray, [intersection])
        let actualValue = world.reflectedColorAt(computations, 0)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorWithOpaqueSurface() throws {
        let world = testWorld()
        let firstShape = world.objects[0]
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
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
        let material = SolidColor.basicMaterial()
            .transparency(1.0)
            .refractive(1.5)
        firstShape.material = material
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
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
        let material = SolidColor.basicMaterial()
            .transparency(1.0)
            .refractive(1.5)
        firstShape.material = material
        let ray = Ray(Point(0, 0, sqrt(2)/2), Vector(0, 1, 0))
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
        class TestPattern: ScintillaLib.Pattern {
            override init(_ transform: Matrix4, _ properties: MaterialProperties = MaterialProperties()) {
                super.init(transform, properties)
            }

            override func colorAt(_ patternPoint: Tuple4) -> Color {
                return Color(patternPoint[0], patternPoint[1], patternPoint[2])
            }
        }

        let world = testWorld()
        let shapeA = world.objects[0]
        let materialA = TestPattern(.identity)
            .ambient(1.0)
        shapeA.material = materialA

        let shapeB = world.objects[1]
        let materialB = SolidColor.basicMaterial()
            .transparency(1.0)
            .refractive(1.5)
        shapeB.material = materialB

        let ray = Ray(Point(0, 0, 0.1), Vector(0, 1, 0))
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
        let world = testWorld()
        let floor = Plane()
            .material(.basicMaterial()
                .transparency(0.5)
                .refractive(1.5))
            .translate(0, -1, 0)
        let ball = Sphere()
            .material(SolidColor(1, 0, 0)
                .ambient(0.5))
            .translate(0, -3.5, -0.5)
        world.objects.append(contentsOf: [floor, ball])

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), floor)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93642, 0.68642, 0.68642)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForTotalInternalReflection() throws {
        let glass = SolidColor(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            PointLight(Point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(Point(0, 0, sqrt(2)/2), Vector(0, 1, 0))
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
        let glass = SolidColor(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            PointLight(Point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(Point(0, 0, 0), Vector(0, 1, 0))
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
        let glass = SolidColor(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            PointLight(Point(-10, 10, -10))
            Camera(800, 600, PI/3, .view(
                Point(0, 1, -1),
                Point(0, 0, 0),
                Vector(0, 1, 0)))
            glassySphere
        }

        let ray = Ray(Point(0, 0.99, -2), Vector(0, 0, 1))
        let intersection = Intersection(1.8589, glassySphere)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.schlickReflectance(computations)
        let expectedValue = 0.48873
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveAndTransparentMaterial() throws {
        let world = testWorld()
        let floor = Plane()
            .material(.basicMaterial()
                .transparency(0.5)
                .reflective(0.5)
                .refractive(1.5))
            .translate(0, -1, 0)

        let ball = Sphere()
            .material(SolidColor(1, 0, 0)
                .ambient(0.5))
            .translate(0, -3.5, -0.5)

        world.objects.append(contentsOf: [floor, ball])

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), floor)
        let allIntersections = [intersection]
        let computations = intersection.prepareComputations(ray, allIntersections)
        let actualValue = world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93391, 0.69643, 0.69243)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRayForPixelForCenterOfCanvas() throws {
        let light = PointLight(Point(-10, 10, -10))
        let camera = Camera(201, 101, PI/2, .identity)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0, 0, -1)))
    }

    func testRayForPixelForCornerOfCanvas() throws {
        let light = PointLight(Point(-10, 10, -10))
        let camera = Camera(201, 101, PI/2, .identity)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(0, 0)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 0, 0)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(0.66519, 0.33259, -0.66851)))
    }

    func testRayForPixelForTransformedCamera() throws {
        let light = PointLight(Point(-10, 10, -10))
        let transform = Matrix4.rotationY(PI/4)
            .multiply(.translation(0, -2, 5))
        let camera = Camera(201, 101, PI/2, transform)
        let objects: [Shape] = []
        let world = World(light, camera, objects)

        let ray = world.rayForPixel(100, 50)
        XCTAssert(ray.origin.isAlmostEqual(Point(0, 2, -5)))
        XCTAssert(ray.direction.isAlmostEqual(Vector(sqrt(2)/2, 0, -sqrt(2)/2)))
    }
}
