//
//  Material.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public class Material {
    var colorStrategy: ColorStrategy
    var ambient: Double
    var diffuse: Double
    var specular: Double
    var shininess: Double
    var reflective: Double
    var transparency: Double
    var refractive: Double

    let defaultAmbient = 0.1
    let defaultDiffuse = 0.9
    let defaultSpecular = 0.9
    let defaultShininess = 200.0
    let defaultReflective = 0.0
    let defaultTransparency = 0.0
    let defaultRefractive = 1.0

    public init(_ colorStrategy: ColorStrategy, _ ambient: Double, _ diffuse: Double, _ specular: Double, _ shininess: Double, _ reflective: Double, _ transparency: Double, _ refractive: Double) {
        self.colorStrategy = colorStrategy
        self.ambient = ambient
        self.diffuse = diffuse
        self.specular = specular
        self.shininess = shininess
        self.reflective = reflective
        self.transparency = transparency
        self.refractive = refractive
    }

    public init(_ colorStrategy: ColorStrategy) {
        self.colorStrategy = colorStrategy
        self.ambient = defaultAmbient
        self.diffuse = defaultDiffuse
        self.specular = defaultSpecular
        self.shininess = defaultShininess
        self.reflective = defaultReflective
        self.transparency = defaultTransparency
        self.refractive = defaultRefractive
    }

    public static func basicMaterial() -> Material {
        return Material(ColorStrategy.solidColor(Color(1, 1, 1)), 0.1, 0.9, 0.9, 200.0, 0.0, 0.0, 1.0)
    }

    public static func solidColor(_ color: Color) -> Material {
        return Material(.solidColor(color))
    }

    public static func pattern(_ pattern: Pattern) -> Material {
        return Material(.pattern(pattern))
    }

    public func ambient(_ ambient: Double) -> Self {
        self.ambient = ambient

        return self
    }

    public func diffuse(_ diffuse: Double) -> Self {
        self.diffuse = diffuse

        return self
    }

    public func specular(_ specular: Double) -> Self {
        self.specular = specular

        return self
    }

    public func shininess(_ shininess: Double) -> Self {
        self.shininess = shininess

        return self
    }

    public func reflective(_ reflective: Double) -> Self {
        self.reflective = reflective

        return self
    }

    public func transparency(_ transparency: Double) -> Self {
        self.transparency = transparency

        return self
    }

    public func refractive(_ refractive: Double) -> Self {
        self.refractive = refractive

        return self
    }

    func lighting(_ light: Light, _ object: Shape, _ point: Tuple4, _ eye: Tuple4, _ normal: Tuple4, _ isShadowed: Bool) -> Color {
        // Combine the surface color with the light's color/intensity
        var effectiveColor: Color
        switch self.colorStrategy {
        case .solidColor(let color):
            effectiveColor = color.hadamard(light.intensity)
        case .pattern(let pattern):
            effectiveColor = pattern.colorAt(object, point)
        }

        // Find the direction to the light source
        let lightDirection = light.position.subtract(point).normalize()

        // Compute the ambient contribution
        let ambient = effectiveColor.multiplyScalar(self.ambient)

        // light_dot_normal represents the cosine of the angle between the
        // light vector and the normal vector. A negative number means the
        // light is on the other side of the surface.
        let lightDotNormal = lightDirection.dot(normal)

        var diffuse: Color
        var specular: Color
        if lightDotNormal < 0 || isShadowed == true {
            diffuse = .black
            specular = .black
        } else {
            // Compute the diffuse contribution
            diffuse = effectiveColor.multiplyScalar(self.diffuse * lightDotNormal)

            // reflect_dot_eye represents the cosine of the angle between the
            // reflection vector and the eye vector. A negative number means the
            // light reflects away from the eye.
            let reflected = lightDirection.negate().reflect(normal)
            let reflectDotEye = reflected.dot(eye)

            if reflectDotEye <= 0 {
                specular = .black
            } else {
                // Compute the specular contribution
                let factor = pow(reflectDotEye, self.shininess)
                specular = light.intensity.multiplyScalar(self.specular * factor)
            }
        }

        return ambient.add(diffuse).add(specular)
    }
}
