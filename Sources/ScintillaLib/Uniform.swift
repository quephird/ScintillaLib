//
//  SolidColor.swift
//  
//
//  Created by Danielle Kefford on 12/20/22.
//

public struct Uniform: Material {
    var color: Color
    public var properties: MaterialProperties

    public init(
        _ component1: Double,
        _ component2: Double,
        _ component3: Double,
        _ colorSpace: ColorSpace = .rgb,
        _ properties: MaterialProperties = MaterialProperties()) {
        self.color = colorSpace.makeColor(component1, component2, component3)
        self.properties = properties
    }

    public init(_ color: Color,
                _ properties: MaterialProperties = MaterialProperties()) {
        self.color = color
        self.properties = properties
    }

    public func colorAt(_ object: any Shape, _ worldPoint: Point) -> Color {
        return color
    }

    public func copy() -> Uniform {
        Uniform(self.color.r, self.color.g, self.color.b, .rgb, self.properties)
    }
}
