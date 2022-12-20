//
//  Material.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct MaterialProperties {
    var ambient: Double
    var diffuse: Double
    var specular: Double
    var shininess: Double
    var reflective: Double
    var transparency: Double
    var refractive: Double

    public static let defaultAmbient = 0.1
    public static let defaultDiffuse = 0.9
    public static let defaultSpecular = 0.9
    public static let defaultShininess = 200.0
    public static let defaultReflective = 0.0
    public static let defaultTransparency = 0.0
    public static let defaultRefractive = 1.0

    public init(_ ambient: Double = Self.defaultAmbient, _ diffuse: Double = Self.defaultDiffuse, _ specular: Double = Self.defaultSpecular, _ shininess: Double = Self.defaultShininess, _ reflective: Double = Self.defaultReflective, _ transparency: Double = Self.defaultTransparency, _ refractive: Double = Self.defaultRefractive) {
        self.ambient = ambient
        self.diffuse = diffuse
        self.specular = specular
        self.shininess = shininess
        self.reflective = reflective
        self.transparency = transparency
        self.refractive = refractive
    }

}

//public class Material {
public protocol Material {
    func copy() -> Self
    func colorAt(_ object: Shape, _ worldPoint: Point) -> Color
    var properties: MaterialProperties { get set }
}

extension Material where Self == SolidColor {
    public static func basicMaterial() -> Self {
        return SolidColor(1, 1, 1)
    }

    public static func solidColor(_ color: SolidColor) -> Self {
        return color
    }
}

extension Material where Self == Pattern {
    public static func pattern(_ pattern: Pattern) -> Self {
        return pattern
    }
}

extension Material where Self == ColorFunction {
    public static func colorFunction(_ colorFunction: @escaping ColorFunctionType) -> Self {
        return ColorFunction(colorFunction)
    }
}

extension Material {
    func modifyingProperties(_ body: (inout MaterialProperties) -> Void) -> Self {
        var copy = self
        body(&copy.properties)
        return copy
    }

    public func ambient(_ ambient: Double) -> Self {
        return modifyingProperties { $0.ambient = ambient }
    }

    public func diffuse(_ diffuse: Double) -> Self {
        return modifyingProperties { $0.diffuse = diffuse }
    }

    public func specular(_ specular: Double) -> Self {
        return modifyingProperties { $0.specular = specular }
    }

    public func shininess(_ shininess: Double) -> Self {
        return modifyingProperties { $0.shininess = shininess }
    }

    public func reflective(_ reflective: Double) -> Self {
        return modifyingProperties { $0.reflective = reflective }
    }

    public func transparency(_ transparency: Double) -> Self {
        return modifyingProperties { $0.transparency = transparency }
    }

    public func refractive(_ refractive: Double) -> Self {
        return modifyingProperties { $0.refractive = refractive }
    }

    func lighting(_ light: Light, _ object: Shape, _ point: Point, _ eye: Vector, _ normal: Vector, _ intensity: Double) -> Color {
        // Combine the surface color with the light's color/intensity
        var effectiveColor: Color = colorAt(object, point)
//        switch self.colorStrategy {
//        case .solidColor(let color):
//            effectiveColor = color
//        case .pattern(let pattern):
//            effectiveColor = pattern.colorAt(object, point)
//        case .colorFunction(let colorFunction):
//            effectiveColor = colorFunction.colorAt(object, point)
//        }
        effectiveColor = effectiveColor.hadamard(light.color)

        // Compute the ambient contribution
        let ambient = effectiveColor.multiplyScalar(self.properties.ambient)

        switch light {
        case let pointLight as PointLight:
            let (diffuse, specular) = self.calculateDiffuseAndSpecular(pointLight.position, pointLight.color, point, effectiveColor, eye, normal, intensity)
            return ambient.add(diffuse).add(specular)
        case var areaLight as AreaLight:
            var diffuseSamples: Color = .black
            var specularSamples: Color = .black

            for u in 0..<areaLight.uSteps {
                for v in 0..<areaLight.vSteps {
                    let pointOnLight = areaLight.pointAt(u, v)
                    let (diffuse, specular) = self.calculateDiffuseAndSpecular(pointOnLight, areaLight.color, point, effectiveColor, eye, normal, intensity)
                    diffuseSamples = diffuseSamples.add(diffuse)
                    specularSamples = specularSamples.add(specular)
                }
            }

            let diffuseAverage = diffuseSamples.divideScalar(Double(areaLight.samples))
            let specularAverage = specularSamples.divideScalar(Double(areaLight.samples))

            return ambient.add(diffuseAverage).add(specularAverage)
        default:
            fatalError("Whoops... encountered unsupported light implementation")
        }
    }

    private func calculateDiffuseAndSpecular(
        _ pointOnLight: Point,
        _ lightColor: Color,
        _ point: Point,
        _ effectiveColor: Color,
        _ eye: Vector,
        _ normal: Vector,
        _ intensity: Double
    ) -> (Color, Color) {
        // Find the direction to the light source
        let lightDirection = pointOnLight.subtract(point).normalize()

        // light_dot_normal represents the cosine of the angle between the
        // light vector and the normal vector. A negative number means the
        // light is on the other side of the surface.
        let lightDotNormal = lightDirection.dot(normal)

        var diffuse: Color
        var specular: Color
        if lightDotNormal < 0 {
            diffuse = .black
            specular = .black
        } else {
            // Compute the diffuse contribution
            diffuse = effectiveColor.multiplyScalar(self.properties.diffuse * lightDotNormal)

            // reflect_dot_eye represents the cosine of the angle between the
            // reflection vector and the eye vector. A negative number means the
            // light reflects away from the eye.
            let reflected = lightDirection.negate().reflect(normal)
            let reflectDotEye = reflected.dot(eye)

            if reflectDotEye <= 0 {
                specular = .black
            } else {
                // Compute the specular contribution
                let factor = pow(reflectDotEye, self.properties.shininess)
                specular = lightColor.multiplyScalar(self.properties.specular * factor)
            }
        }
        diffuse = diffuse.multiplyScalar(intensity)
        specular = specular.multiplyScalar(intensity)

        return (diffuse, specular)
    }
}
