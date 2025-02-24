//
//  Material.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public struct MaterialProperties {
    @_spi(Testing) public var ambient: Double
    @_spi(Testing) public var diffuse: Double
    @_spi(Testing) public var specular: Double
    @_spi(Testing) public var shininess: Double
    @_spi(Testing) public var reflective: Double
    @_spi(Testing) public var transparency: Double
    @_spi(Testing) public var refractive: Double

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

public protocol Material {
    var transform: Matrix4 { get set }
    var inverseTransform: Matrix4 { get }
    var inverseTransposeTransform: Matrix4 { get }
    func copy() -> Self
    func colorAt(_ object: any Shape, _ worldPoint: Point) -> Color
    var properties: MaterialProperties { get set }
}

// Property modification extensions
extension Material {
    public func translate(_ x: Double, _ y: Double, _ z: Double) -> Self {
        var copy = self
        copy.transform = .translation(x, y, z).multiply(copy.transform)

        return copy
    }

    public func scale(_ x: Double, _ y: Double, _ z: Double) -> Self {
        var copy = self
        copy.transform = .scaling(x, y, z).multiply(copy.transform)

        return copy
    }

    public func rotateX(_ t: Double) -> Self {
        var copy = self
        copy.transform = .rotationX(t).multiply(copy.transform)

        return copy
    }

    public func rotateY(_ t: Double) -> Self {
        var copy = self
        copy.transform = .rotationY(t).multiply(copy.transform)

        return copy
    }

    public func rotateZ(_ t: Double) -> Self {
        var copy = self
        copy.transform = .rotationZ(t).multiply(copy.transform)

        return copy
    }

    public func shear(_ xy: Double, _ xz: Double, _ yx: Double, _ yz: Double, _ zx: Double, _ zy: Double) -> Self {
        var copy = self
        copy.transform = .shearing(xy, xz, yx, yz, zx, zy).multiply(copy.transform)

        return copy
    }
}

extension Material where Self == Uniform {
    public static func basicMaterial() -> Self {
        return Uniform(1, 1, 1)
    }

    public static func uniform(_ component0: Double,
                               _ component1: Double,
                               _ component2: Double,
                               _ colorSpace: ColorSpace = .rgb) -> Self {
        return Uniform(component0, component1, component2, colorSpace)
    }

    public static func uniform(_ color: Color) -> Self {
        return Uniform(color.r, color.g, color.b)
    }
}

extension Material where Self == Pattern {
    public static func pattern(_ pattern: Pattern) -> Self {
        return pattern
    }
}

extension Material where Self == ColorFunction {
    public static func colorFunction(_ colorSpace: ColorSpace = .rgb, _ colorFunction: @escaping ColorFunctionType) -> Self {
        return ColorFunction(colorSpace, colorFunction)
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

    @_spi(Testing) public func lighting(_ light: Light, _ object: any Shape, _ point: Point, _ eye: Vector, _ normal: Vector, _ intensity: Double) -> Color {
        // Account for the attenuation of the light source over distance
        // if it has the fadeDistance property set. This is very similar
        // to the approach that POV-Ray uses, documented here:
        //
        // http://www.povray.org/documentation/3.7.0/r3_4.html#r3_4_4_1_9
        var lightColor = light.color
        if let fadeDistance = light.fadeDistance {
            let distance = light.position.distanceBetween(point)
            let attenuation = 2/(1 + pow(distance/fadeDistance, 2))
            lightColor = lightColor.multiplyScalar(attenuation)
        }

        // Combine the surface color with the light's color/intensity
        var effectiveColor: Color = colorAt(object, point)
        effectiveColor = effectiveColor.hadamard(lightColor)

        // Compute the ambient contribution
        let ambient = effectiveColor.multiplyScalar(self.properties.ambient)

        switch light {
        case let pointLight as PointLight:
            let (diffuse, specular) = self.calculateDiffuseAndSpecular(pointLight.position, lightColor, point, effectiveColor, eye, normal, intensity)
            return ambient.add(diffuse).add(specular)
        case var areaLight as AreaLight:
            var diffuseSamples: Color = .black
            var specularSamples: Color = .black

            for u in 0..<areaLight.uSteps {
                for v in 0..<areaLight.vSteps {
                    let pointOnLight = areaLight.pointAt(u, v)
                    let (diffuse, specular) = self.calculateDiffuseAndSpecular(pointOnLight, lightColor, point, effectiveColor, eye, normal, intensity)
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
