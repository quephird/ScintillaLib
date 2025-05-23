//
//  World.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

@_spi(Testing) public let MAX_RECURSIVE_CALLS = 5

public actor World {
    @_spi(Testing) public var camera: Camera
    @_spi(Testing) public var lights: [Light]
    @_spi(Testing) public var shapes: [any Shape]

    var totalPixels: Int

    public init(@WorldBuilder builder: () -> (Camera, [WorldObject])) {
        let (camera, objects) = builder()

        var lights: [Light] = []
        var shapes: [any Shape] = []
        for object in objects {
            switch object {
            case .light(let light):
                lights.append(light)
            case .shape(let shape):
                shapes.append(shape)
            }
        }

        self.camera = camera
        self.lights = lights
        self.shapes = shapes
        self.totalPixels = camera.horizontalSize * camera.verticalSize

        self.assignIds()
    }

    public init(_ camera: Camera, @WorldObjectBuilder builder: () -> [WorldObject]) {
        let objects = builder()
        var lights: [Light] = []
        var shapes: [any Shape] = []
        for object in objects {
            switch object {
            case .light(let light):
                lights.append(light)
            case .shape(let shape):
                shapes.append(shape)
            }
        }

        self.lights = lights
        self.shapes = shapes
        self.camera = camera
        self.totalPixels = camera.horizontalSize * camera.verticalSize

        self.assignIds()
    }

    public init(_ camera: Camera, _ lights: [Light], _ shapes: [any Shape]) {
        self.camera = camera
        self.lights = lights
        self.shapes = shapes
        self.totalPixels = camera.horizontalSize * camera.verticalSize

        self.assignIds()
    }

    private func assignIds() {
        self.shapes = self.shapes.enumerated().map { (index, shape) in
            var copy = shape
            return copy.assignId(id: [UInt8(index)])
        }
    }

    @_spi(Testing) public func intersect(_ ray: Ray) -> [Intersection] {
        var intersections = self.shapes.flatMap({shape in shape.intersect(ray)})
        intersections
            .sort(by: { i1, i2 in
                i1.t < i2.t
            })
        return intersections
    }

    func schlickReflectanceHelper(_ n1: Double, _ n2: Double, _ cosTheta: Double) -> Double {
        let r0 = pow((n1 - n2) / (n1 + n2), 2.0)
        return r0 + (1 - r0) * pow(1 - cosTheta, 5.0)
    }

    @_spi(Testing) public func schlickReflectance(_ computations: Computations) -> Double {
        // Find the cosine of the angle between the eye and normal vectors
        let cosThetaI = computations.eye.dot(computations.normal)

        // Total internal reflection can only occur if n1 > n2
        if computations.n1 > computations.n2 {
            let ratio = computations.n1 / computations.n2
            let sin2ThetaT = ratio*ratio * (1.0 - cosThetaI*cosThetaI)

            if sin2ThetaT > 1.0 {
                return 1.0
            } else {
               // Compute cos(theta_t) using trig identity
               let cosThetaT = sqrt(1.0 - sin2ThetaT)
               // When n1 > n2, use cos(theta_t) instead
                return schlickReflectanceHelper(computations.n1, computations.n2, cosThetaT)
            }
        } else {
            return schlickReflectanceHelper(computations.n1, computations.n2, cosThetaI)
        }
    }

    @_spi(Testing) public func shadeHit(_ computations: Computations, _ remainingCalls: Int) async -> Color {
        let material = computations.object.material

        var surfaceColor = Color(0, 0, 0)
        for light in self.lights {
            let intensity = self.intensity(light, computations.overPoint)

            let tempColor = material.lighting(light,
                                              computations.object,
                                              computations.point,
                                              computations.eye,
                                              computations.normal,
                                              intensity)

            // This may or may not be a hack to combine colors instead of simply
            // adding them and potentially winding up with color components
            // greater than 255 and a scene that is way too bright. It was inspired
            // by the following post on Stack Overflow:
            //
            // https://stackoverflow.com/questions/4133351/how-to-blend-colors
            surfaceColor = surfaceColor.blend(tempColor)
        }

        let reflectedColor = await self.reflectedColorAt(computations, remainingCalls)
        let refractedColor = await self.refractedColorAt(computations, remainingCalls)

        if material.properties.reflective > 0 && material.properties.transparency > 0 {
            let reflectance = self.schlickReflectance(computations)
            return surfaceColor
                .add(reflectedColor.multiplyScalar(reflectance))
                .add(refractedColor.multiplyScalar(1 - reflectance))
        } else {
            return surfaceColor.add(reflectedColor).add(refractedColor)
        }
    }

    @_spi(Testing) public func reflectedColorAt(_ computations: Computations, _ remainingCalls: Int) async -> Color {
        if remainingCalls == 0 {
            return .black
        } else if computations.object.material.properties.reflective == 0 {
            return .black
        } else {
            let reflected = Ray(computations.overPoint, computations.reflected)
            return await self.colorAt(reflected, remainingCalls-1).multiplyScalar(computations.object.material.properties.reflective)
        }
    }

    @_spi(Testing) public func refractedColorAt(_ computations: Computations, _ remainingCalls: Int) async -> Color {
        if remainingCalls == 0 {
            return .black
        } else if computations.object.material.properties.transparency == 0 {
            return .black
        } else {
            // Find the ratio of first index of refraction to the second.
            // (Yup, this is inverted from the definition of Snell's Law.)
            let ratio = computations.n1 / computations.n2

            // cos(theta_i) is the same as the dot product of the two vectors
            let cosThetaI = computations.eye.dot(computations.normal)

            // Find sin(theta_t)^2 via trigonometric identity
            let sin2ThetaT = ratio*ratio * (1 - cosThetaI*cosThetaI)

            if sin2ThetaT > 1 {
                return .black
            } else {
                // Find cos(theta_t) via trigonometric identity
                let cosThetaT = sqrt(1.0 - sin2ThetaT)

                // Compute the direction of the refracted ray
                let direction = computations.normal
                    .multiply(ratio * cosThetaI - cosThetaT)
                    .subtract(computations.eye.multiply(ratio))

                // Create the refracted ray
                let refracted = Ray(computations.underPoint, direction)

                // Find the color of the refracted ray, making sure to multiply
                // by the transparency value to account for any opacity
                return await self.colorAt(refracted, remainingCalls - 1)
                    .multiplyScalar(computations.object.material.properties.transparency)
            }
        }
    }

    @_spi(Testing) public func colorAt(_ ray: Ray, _ remainingCalls: Int) async -> Color {
        let allIntersections = self.intersect(ray)
        let hit = hit(allIntersections)
        switch hit {
        case .none:
            return .black
        case .some(let intersection):
            let computations = await intersection.prepareComputations(self, ray, allIntersections)
            return await self.shadeHit(computations, remainingCalls)
        }
    }

    @_spi(Testing) public func isShadowed(_ lightPoint: Point, _ worldPoint: Point) -> Bool {
        let lightVector = lightPoint.subtract(worldPoint)
        let lightDistance = lightVector.magnitude()
        let lightDirection = lightVector.normalize()
        let lightRay = Ray(worldPoint, lightDirection)
        let intersections = self.intersect(lightRay)
        let hit = hit(intersections, includeOnlyShadowingObjects: true)

        if hit != nil && hit!.t < lightDistance {
            return true
        } else {
            return false
        }
    }

    @_spi(Testing) public func intensity(_ light: Light, _ worldPoint: Point) -> Double {
        switch light {
        case let pointLight as PointLight:
            return isShadowed(pointLight.position, worldPoint) ? 0.0 : 1.0
        case var areaLight as AreaLight:
            var intensity: Double = 0.0
            for u in 0..<areaLight.uSteps {
                for v in 0..<areaLight.vSteps {
                    let pointOnLight = areaLight.pointAt(u, v)
                    intensity += isShadowed(pointOnLight, worldPoint) ? 0.0 : 1.0
                }
            }

            return intensity/Double(areaLight.samples)
        case let spotLight as SpotLight:
            return isShadowed(spotLight.position, worldPoint) ? 0.0 : 1.0
        default:
            fatalError("Whoops! Encountered unsupported light implementation!")
        }
    }

    private func sendProgress(newPercentRendered: Double,
                              newElapsedTime: Range<Date>,
                              to updateClosure: @MainActor @escaping (Double, Range<Date>) -> Void) {
        Task { await updateClosure(newPercentRendered, newElapsedTime) }
    }

    public func render(
        updateClosure: @MainActor @escaping (Double, Range<Date>) -> Void
    ) async throws -> Canvas {
        var renderedPixels = 0
        var percentRendered = 0.0
        let startingTime = Date()
        sendProgress(newPercentRendered: percentRendered,
                     newElapsedTime: startingTime..<startingTime,
                     to: updateClosure)
        var canvas = Canvas(self.camera.horizontalSize, self.camera.verticalSize)
        for y in 0..<self.camera.verticalSize {
            for x in 0..<self.camera.horizontalSize {
                var colorSamples: Color = .black

                let rays = self.camera.raysForPixel(x: x, y: y)
                for ray in rays {
                    let colorSample = await self.colorAt(ray, MAX_RECURSIVE_CALLS)
                    colorSamples = colorSamples.add(colorSample)
                }

                let color = colorSamples.divideScalar(Double(rays.count))
                canvas.setPixel(x, y, color)
                renderedPixels += 1
            }

            try Task.checkCancellation()
            percentRendered = Double(renderedPixels)/Double(self.totalPixels)
            sendProgress(newPercentRendered: percentRendered,
                         newElapsedTime: startingTime ..< Date(),
                         to: updateClosure)
        }
        return canvas
    }
}
