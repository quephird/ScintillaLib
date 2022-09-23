//
//  World.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/23/21.
//

import Foundation

let MAX_RECURSIVE_CALLS = 5

struct World {
    var light: Light
    var camera: Camera
    var objects: [Shape]

    init(@WorldBuilder builder: () -> (Light, Camera, [Shape])) {
        let (light, camera, shapes) = builder()
        self.light = light
        self.camera = camera
        self.objects = shapes
    }

    init(_ light: Light, _ camera: Camera, @ShapeBuilder builder: () -> [Shape]) {
        self.light = light
        self.camera = camera
        self.objects = builder()
    }

    init(_ light: Light, _ camera: Camera, _ objects: [Shape]) {
        self.light = light
        self.camera = camera
        self.objects = objects
    }

    func intersect(_ ray: Ray) -> [Intersection] {
        var intersections = objects.flatMap({object in object.intersect(ray)})
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

    func schlickReflectance(_ computations: Computations) -> Double {
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

    func shadeHit(_ computations: Computations, _ remainingCalls: Int) -> Color {
        let material = computations.object.material
        let isShadowed = self.isShadowed(computations.overPoint)

        let surfaceColor = material.lighting(
            self.light,
            computations.object,
            computations.point,
            computations.eye,
            computations.normal,
            isShadowed
        )

        let reflectedColor = self.reflectedColorAt(computations, remainingCalls)
        let refractedColor = self.refractedColorAt(computations, remainingCalls)

        if material.reflective > 0 && material.transparency > 0 {
            let reflectance = self.schlickReflectance(computations)
            return surfaceColor
                .add(reflectedColor.multiplyScalar(reflectance))
                .add(refractedColor.multiplyScalar(1 - reflectance))
        } else {
            return surfaceColor.add(reflectedColor).add(refractedColor)
        }
    }

    func reflectedColorAt(_ computations: Computations, _ remainingCalls: Int) -> Color {
        if remainingCalls == 0 {
            return .black
        } else if computations.object.material.reflective == 0 {
            return .black
        } else {
            let reflected = Ray(computations.overPoint, computations.reflected)
            return self.colorAt(reflected, remainingCalls-1).multiplyScalar(computations.object.material.reflective)
        }
    }

    func refractedColorAt(_ computations: Computations, _ remainingCalls: Int) -> Color {
        if remainingCalls == 0 {
            return .black
        } else if computations.object.material.transparency == 0 {
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
                    .multiplyScalar(ratio * cosThetaI - cosThetaT)
                    .subtract(computations.eye.multiplyScalar(ratio))

                // Create the refracted ray
                let refracted = Ray(computations.underPoint, direction)

                // Find the color of the refracted ray, making sure to multiply
                // by the transparency value to account for any opacity
                return self.colorAt(refracted, remainingCalls - 1)
                    .multiplyScalar(computations.object.material.transparency)
            }
        }
    }

    func colorAt(_ ray: Ray, _ remainingCalls: Int) -> Color {
        var allIntersections = self.intersect(ray)
        let hit = hit(&allIntersections)
        switch hit {
        case .none:
            return .black
        case .some(let intersection):
            let computations = intersection.prepareComputations(ray, allIntersections)
            return self.shadeHit(computations, remainingCalls)
        }
    }

    func isShadowed(_ point: Tuple4) -> Bool {
        let lightVector = self.light.position.subtract(point)
        let lightDistance = lightVector.magnitude()
        let lightDirection = lightVector.normalize()
        let lightRay = Ray(point, lightDirection)
        var intersections = self.intersect(lightRay)
        let hit = hit(&intersections)

        if hit != nil && hit!.t < lightDistance {
            return true
        } else {
            return false
        }
    }

    func rayForPixel(_ pixelX: Int, _ pixelY: Int) -> Ray {
        // The offset from the edge of the canvas to the pixel's center
        let offsetX = (Double(pixelX) + 0.5) * self.camera.pixelSize
        let offsetY = (Double(pixelY) + 0.5) * self.camera.pixelSize

        // The untransformed coordinates of the pixel in world space.
        // (Remember that the camera looks toward -z, so +x is to the *left*.)
        let worldX = self.camera.halfWidth - offsetX
        let worldY = self.camera.halfHeight - offsetY

        // Using the camera matrix, transform the canvas point and the origin,
        // and then compute the ray's direction vector.
        // (Remember that the canvas is at z=-1)
        let pixel = self.camera.inverseViewTransform.multiplyTuple(point(worldX, worldY, -1))
        let origin = self.camera.inverseViewTransform.multiplyTuple(point(0, 0, 0))
        let direction = pixel.subtract(origin).normalize()

        return Ray(origin, direction)
    }

    func render() -> Canvas {
        var canvas = Canvas(self.camera.horizontalSize, self.camera.verticalSize)
        for y in 0...self.camera.verticalSize-1 {
            for x in 0...self.camera.horizontalSize-1 {
                let ray = self.rayForPixel(x, y)
                let color = self.colorAt(ray, MAX_RECURSIVE_CALLS)
                canvas.setPixel(x, y, color)
            }
        }
        return canvas
    }
}

