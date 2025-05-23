//
//  WorldTests.swift
//  ScintillaTests
//
//  Created by Danielle Kefford on 11/23/21.
//

import XCTest
@_spi(Testing) import ScintillaLib

let testCamera = Camera(width: 800,
                        height: 600,
                        viewAngle:PI/3,
                        from: Point(0, 1, -1),
                        to: Point(0, 0, 0),
                        up: Vector(0, 1, 0))

func testWorld() -> World {
    World {
        Camera(width: 800,
               height: 600,
               viewAngle: PI/3,
               from: Point(0, 1, -1),
               to: Point(0, 0, 0),
               up: Vector(0, 1, 0))
        PointLight(position: Point(-10, 10, -10))
        Sphere()
            .material(Uniform(0.8, 1.0, 0.6)
                .ambient(0.1)
                .diffuse(0.7)
                .specular(0.2)
                .refractive(0.0))
        Sphere()
            .scale(0.5, 0.5, 0.5)
    }
}

class WorldTests: XCTestCase {
    func testIntersect() async throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let intersections = await world.intersect(ray)
        XCTAssertEqual(intersections.count, 4)
        XCTAssert(intersections[0].t.isAlmostEqual(4))
        XCTAssert(intersections[1].t.isAlmostEqual(4.5))
        XCTAssert(intersections[2].t.isAlmostEqual(5.5))
        XCTAssert(intersections[3].t.isAlmostEqual(6))
    }

    func testShadeHit() async throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let shape = await world.shapes[0]
        let intersection = Intersection(4, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.38066, 0.47583, 0.28549)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitInside() async throws {
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(0, 0.25, 0), color: Color(1, 1, 1))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
        }

        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let shape = await world.shapes[1]
        let intersection = Intersection(0.5, shape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.90498, 0.90498, 0.90498)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitIntersectionInShadow() async throws {
        let s1 = Sphere()
        let s2 = Sphere()
            .translate(0, 0, 10)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(0, 0, -10), color: Color(1, 1, 1))
            s1
            s2
        }

        let ray = Ray(Point(0, 0, 5), Vector(0, 0, 1))
        let assignedS2 = await world.shapes[1]
        let intersection = Intersection(4, assignedS2)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.1, 0.1, 0.1)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtMiss() async throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 1, 0))
        let actualValue = await world.colorAt(ray, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtHit() async throws {
        let world = testWorld()
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let actualValue = await world.colorAt(ray, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.38066, 0.47583, 0.2855)
        XCTAssert(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtForSpotLightPointedAtPlane() async throws {
        let world = World {
            Camera(width: 400,
                   height: 400,
                   viewAngle: PI/3,
                   from: Point(0, 2, -7),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            SpotLight(position:  Point(0, 5, 0),
                      pointAt:  Point(0, 0, 0),
                      beamAngle: PI/12,
                      falloffAngle: PI/6,
                      tightness: 1)
            Plane()
                .material(.uniform(1, 1, 1))
        }

        let eye = Point(0, 2, -5)
        let testCases = [
            // Looking at the center of the spot on the plane
            (Vector(0, -2, 5), Color(1.0, 1.0, 1.0)),
            // Looking at edge of inner cone on plane
            (Vector(5*tan(PI/12), -2, 5), Color(0.96933, 0.96933, 0.96933)),
            // Looking at point between cones on plane
            (Vector(5*tan(3.0*PI/24.0), -2, 5), Color(0.37886, 0.37886, 0.37886)),
            // Looking at edge of outer cone on plane
            (Vector(5*tan(PI/6), -2, 5), Color(0.1, 0.1, 0.1)),
            // Looking far outside outer cone on plane
            (Vector(5*tan(PI/3), -2, 5), Color(0.1, 0.1, 0.1)),
        ]

        for (direction, expectedColor) in testCases {
            let ray = Ray(eye, direction.normalize())
            let actualColor = await world.colorAt(ray, MAX_RECURSIVE_CALLS)
            XCTAssert(actualColor.isAlmostEqual(expectedColor))
        }
    }

    //    Ignore this test for now
    //
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

    func testIsShadowedPointAndLightNotCollinear() async throws {
        let world = testWorld()
        let worldPoint = Point(0, 10, 0)
        let light = await world.lights[0]
        let result = await world.isShadowed(light.position, worldPoint)
        XCTAssertFalse(result)
    }

    func testIsShadowedObjectBetweenPointAndLight() async throws {
        let world = testWorld()
        let worldPoint = Point(10, -10, 10)
        let light = await world.lights[0]
        let result = await world.isShadowed(light.position, worldPoint)
        XCTAssertTrue(result)
    }

    func testIsShadowedObjectBehindLight() async throws {
        let world = testWorld()
        let worldPoint = Point(-20, 20, -20)
        let light = await world.lights[0]
        let result = await world.isShadowed(light.position, worldPoint)
        XCTAssertFalse(result)
    }

    func testIsShadowedObjectBehindPoint() async throws {
        let world = testWorld()
        let worldPoint = Point(-2, 2, -2)
        let light = await world.lights[0]
        let result = await world.isShadowed(light.position, worldPoint)
        XCTAssertFalse(result)
    }

    func testIntensityOfPointLight() async throws {
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
        let light = await world.lights[0]

        for (worldPoint, expectedIntensity) in testCases {
            let actualIntesity = await world.intensity(light, worldPoint)
            XCTAssertEqual(actualIntesity, expectedIntensity)
        }
    }

    func testIntensityOfAreaLightWithNoJitter() async throws {
        let areaLight = AreaLight(corner: Point(-0.5, -0.5, -5),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(1, 0, 0),
                                  uSteps: 2,
                                  vVec: Vector(0, 1, 0),
                                  vSteps: 2,
                                  jitter: NoJitter())
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            areaLight
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
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
            let actualIntensity = await world.intensity(areaLight, worldPoint)
            XCTAssertEqual(actualIntensity, expectedIntensity)
        }
    }

    func testIntensityOfSpotLightWithSphereAndPlane() async throws {
        let spotLight = SpotLight(position:  Point(0, 5, 0),
                                  pointAt:  Point(0, 0, 0),
                                  beamAngle: PI/12,
                                  falloffAngle: PI/6,
                                  tightness: 1)
        let world = World {
            Camera(width: 400,
                   height: 400,
                   viewAngle: PI/3,
                   from: Point(0, 2, -7),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            spotLight
            Sphere()
                .translate(0, 1, 0)
                .material(.uniform(1, 0, 0))
            Plane()
                .material(.uniform(1, 1, 1))
        }

        let testCases = [
            (Point(1, 0, 0), 0.0), // Point well inside shadow of sphere on x-axis
            (Point(0, 0, -1), 0.0), // Point well inside shadow of sphere on z-axis
            (Point(5.0*tan(asin(1/4)) - 0.001, 0, 0), 0.0), // Point _just_ inside shadow of sphere
            (Point(5.0*tan(asin(1/4)) + 0.001, 0, 0), 1.0), // Point _just_ outside shadow of sphere
        ]
        for (worldPoint, expectedIntensity) in testCases {
            let actualIntensity = await world.intensity(spotLight, worldPoint)
            XCTAssertEqual(actualIntensity, expectedIntensity)
        }
    }

    func testIntensityOfAreaLightWithPseduorandomJitter() async throws {
        let areaLight = AreaLight(corner: Point(-0.5, -0.5, -5),
                                  color: Color(1, 1, 1),
                                  uVec: Vector(1, 0, 0),
                                  uSteps: 2,
                                  vVec: Vector(0, 1, 0),
                                  vSteps: 2,
                                  jitter: PseudorandomJitter([0.7, 0.3, 0.9, 0.1, 0.5]))
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            areaLight
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
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
            let actualIntensity = await world.intensity(areaLight, worldPoint)
            XCTAssertEqual(actualIntensity, expectedIntensity)
            print(actualIntensity)
        }
    }

    func testReflectedColorForNonreflectiveMaterial() async {
        let secondShape = Sphere()
            .material(Uniform(1.0, 1.0, 1.0)
                .ambient(1.0))
            .scale(0.5, 0.5, 0.5)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            secondShape
        }

        let ray = Ray(Point(0, 0, 0), Vector(0, 0, 1))
        let assignedSecondShape = await world.shapes[1]
        let intersection = Intersection(1, assignedSecondShape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.reflectedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveMaterial() async throws {
        let anotherShape = Plane()
            .material(.basicMaterial()
                .reflective(0.5))
            .translate(0, -1, 0)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
            anotherShape
        }

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let assignedAnotherShape = await world.shapes[2]
        let intersection = Intersection(sqrt(2), assignedAnotherShape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.87676, 0.92434, 0.82917)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testColorAtTerminatesForWorldWithMutuallyReflectiveSurfaces() async throws {
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(0, 0, 0))
            Plane()
                .material(.basicMaterial().reflective(1.0))
                .translate(0, -1, 0)
            Plane()
                .material(.basicMaterial().reflective(1.0))
                .translate(0, 1, 0)
        }
        let ray = Ray(Point(0, 0, 0), Vector(0, 1, 0))

        // The following call should terminate; no need to test return value
        let _ = await world.colorAt(ray, MAX_RECURSIVE_CALLS)
    }

    func testColorAtMaxRecursiveDepth() async throws {
        let additionalShape = Plane()
            .material(.basicMaterial().reflective(0.5))
            .translate(0, -1, 0)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
            additionalShape
        }

        let assignedAdditionalShape = await world.shapes[2]
        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let intersection = Intersection(sqrt(2), assignedAdditionalShape)
        let computations = await intersection.prepareComputations(world, ray, [intersection])
        let actualValue = await world.reflectedColorAt(computations, 0)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorWithOpaqueSurface() async throws {
        let world = testWorld()
        let firstShape = await world.shapes[0]
        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let allIntersections = [
            Intersection(4, firstShape),
            Intersection(6, firstShape),
        ]
        let computations = await allIntersections[0].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0, 0)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorAtMaximumRecursiveDepth() async throws {
        let firstShape = Sphere()
            .material(.basicMaterial()
                .transparency(1.0)
                .refractive(1.5))
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            firstShape
            Sphere()
                .scale(0.5, 0.5, 0.5)
        }

        let ray = Ray(Point(0, 0, -5), Vector(0, 0, 1))
        let assignedFirstShape = await world.shapes[0]
        let allIntersections = [
            Intersection(4, assignedFirstShape),
            Intersection(6, assignedFirstShape),
        ]
        let computations = await allIntersections[0].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.refractedColorAt(computations, 0)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorUnderTotalInternalReflection() async throws {
        let firstShape = Sphere()
            .material(.basicMaterial()
                .transparency(1.0)
                .refractive(1.5))
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            firstShape
            Sphere()
                .scale(0.5, 0.5, 0.5)
        }

        let ray = Ray(Point(0, 0, sqrt(2)/2), Vector(0, 1, 0))
        let assignedFirstShape = await world.shapes[0]
        let allIntersections = [
            Intersection(-sqrt(2)/2, assignedFirstShape),
            Intersection(sqrt(2)/2, assignedFirstShape),
        ]
        let computations = await allIntersections[1].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color.black
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testRefractedColorWithRefractedRay() async throws {
        class TestPattern: ScintillaLib.Pattern {
            override init(_ transform: Matrix4, _ properties: MaterialProperties = MaterialProperties()) {
                super.init(transform, properties)
            }

            override func colorAt(_ patternPoint: Tuple4) -> Color {
                return Color(patternPoint[0], patternPoint[1], patternPoint[2])
            }
        }

        let materialA = TestPattern(.identity)
            .ambient(1.0)
        let shapeA = Sphere()
            .material(materialA)

        let materialB = Uniform.basicMaterial()
            .transparency(1.0)
            .refractive(1.5)
        let shapeB = Sphere()
            .material(materialB)
            .scale(0.5, 0.5, 0.5)

        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            shapeA
            shapeB
        }

        let ray = Ray(Point(0, 0, 0.1), Vector(0, 1, 0))
        let assignedShapeA = await world.shapes[0]
        let assignedShapeB = await world.shapes[1]
        let allIntersections = [
            Intersection(-0.9899, assignedShapeA),
            Intersection(-0.4899, assignedShapeB),
            Intersection(0.4899, assignedShapeB),
            Intersection(0.9899, assignedShapeA),
        ]
        let computations = await allIntersections[2].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.refractedColorAt(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0, 0.99888, 0.04722)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithTransparentMaterial() async throws {
        let floor = Plane()
            .material(.basicMaterial()
                .transparency(0.5)
                .refractive(1.5))
            .translate(0, -1, 0)
        let ball = Sphere()
            .material(Uniform(1, 0, 0)
                .ambient(0.5))
            .translate(0, -3.5, -0.5)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
            floor
            ball
        }

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let assignedFloor = await world.shapes[2]
        let intersection = Intersection(sqrt(2), assignedFloor)
        let allIntersections = [intersection]
        let computations = await intersection.prepareComputations(world, ray, allIntersections)
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93642, 0.68642, 0.68642)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForTotalInternalReflection() async throws {
        let glass = Uniform(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            glassySphere
        }

        let ray = Ray(Point(0, 0, sqrt(2)/2), Vector(0, 1, 0))
        let assignedGlassySphere = await world.shapes[0]
        let allIntersections = [
            Intersection(-sqrt(2)/2, assignedGlassySphere),
            Intersection(sqrt(2)/2, assignedGlassySphere),
        ]
        let computations = await allIntersections[1].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.schlickReflectance(computations)
        let expectedValue = 1.0
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForPerpendicularRay() async throws {
        let glass = Uniform(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            glassySphere
        }

        let ray = Ray(Point(0, 0, 0), Vector(0, 1, 0))
        let assignedGlassySphere = await world.shapes[0]
        let allIntersections = [
            Intersection(-1, assignedGlassySphere),
            Intersection(1, assignedGlassySphere),
        ]
        let computations = await allIntersections[1].prepareComputations(world, ray, allIntersections)
        let actualValue = await world.schlickReflectance(computations)
        let expectedValue = 0.04
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testSchlickReflectanceForSmallAngleAndN2GreaterThanN1() async throws {
        let glass = Uniform(1.0, 1.0, 1.0)
            .transparency(1.0)
            .refractive(1.5)
        let glassySphere = Sphere().material(glass)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            glassySphere
        }

        let ray = Ray(Point(0, 0.99, -2), Vector(0, 0, 1))
        let assignedGlassySphere = await world.shapes[0]
        let intersection = Intersection(1.8589, assignedGlassySphere)
        let allIntersections = [intersection]
        let computations = await intersection.prepareComputations(world, ray, allIntersections)
        let actualValue = await world.schlickReflectance(computations)
        let expectedValue = 0.48873
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithReflectiveAndTransparentMaterial() async throws {
        let floor = Plane()
            .material(.basicMaterial()
                .transparency(0.5)
                .reflective(0.5)
                .refractive(1.5))
            .translate(0, -1, 0)
        let ball = Sphere()
            .material(Uniform(1, 0, 0)
                .ambient(0.5))
            .translate(0, -3.5, -0.5)
        let world = World {
            Camera(width: 800,
                   height: 600,
                   viewAngle: PI/3,
                   from: Point(0, 1, -1),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            PointLight(position: Point(-10, 10, -10))
            Sphere()
                .material(Uniform(0.8, 1.0, 0.6)
                    .ambient(0.1)
                    .diffuse(0.7)
                    .specular(0.2)
                    .refractive(0.0))
            Sphere()
                .scale(0.5, 0.5, 0.5)
            floor
            ball
        }

        let ray = Ray(Point(0, 0, -3), Vector(0, -sqrt(2)/2, sqrt(2)/2))
        let assignedFloor = await world.shapes[2]
        let intersection = Intersection(sqrt(2), assignedFloor)
        let allIntersections = [intersection]
        let computations = await intersection.prepareComputations(world, ray, allIntersections)
        let actualValue = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
        let expectedValue = Color(0.93391, 0.69643, 0.69243)
        XCTAssertTrue(actualValue.isAlmostEqual(expectedValue))
    }

    func testShadeHitWithTwoLightsAndVerifyThereAreTwoShadows() async throws {
        let floor = Plane().translate(0, -1, 0)
        let world = World {
            Camera(width: 400,
                   height: 400,
                   viewAngle: PI/3,
                   from: Point(0, 0, -5),
                   to: Point(0, 0, 0),
                   up: Vector(0, 1, 0))
            // Light above and to the left of the sphere
            PointLight(position: Point(-10, 10, 0))
            // Light above and to the right of the sphere
            PointLight(position: Point(10, 10, 0))
            Sphere()
                .material(.uniform(1.0, 1.0, 1.0))
            floor
        }
        let assignedFloor = await world.shapes[1]

        for (direction, t, expectedColor) in [
            // Spot on the plane in the left shadow
            (Vector(-1/sqrt(27), -1/sqrt(27), 5/sqrt(27)), sqrt(27), Color(0.81691, 0.81691, 0.81691)),
            // Spot on the plane in the right shadow
            (Vector(1/sqrt(27), -1/sqrt(27), 5/sqrt(27)), sqrt(27), Color(0.81691, 0.81691, 0.81691)),
            // Spot on the plane in between camera and sphere not in any shadow
            (Vector(0, -1/sqrt(17), 4/sqrt(17)), sqrt(17), Color(0.94451, 0.94451, 0.94451)),
        ] {
            let ray = Ray(Point(0, 0, -5), direction)
            let intersection = Intersection(t, assignedFloor)
            let allIntersections = [intersection]
            let computations = await intersection.prepareComputations(world, ray, allIntersections)
            let actualColor = await world.shadeHit(computations, MAX_RECURSIVE_CALLS)
            XCTAssertTrue(actualColor.isAlmostEqual(expectedColor))
        }
    }
}
