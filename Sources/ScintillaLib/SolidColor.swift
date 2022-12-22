//
//  SolidColor.swift
//  
//
//  Created by Danielle Kefford on 12/20/22.
//

public struct SolidColor: Material {
    var color: Color
    public var properties = MaterialProperties()

    public init(
        _ component1: Double,
        _ component2: Double,
        _ component3: Double,
        _ colorSpace: ColorSpace = .rgb,
        _ properties: MaterialProperties = MaterialProperties()) {
        self.color = colorSpace.makeColor(component1, component2, component3)
    }

    public func colorAt(_ object: Shape, _ worldPoint: Point) -> Color {
        return color
    }

    public func copy() -> SolidColor {
        SolidColor(self.color.r, self.color.g, self.color.b, .rgb, self.properties)
    }
}
