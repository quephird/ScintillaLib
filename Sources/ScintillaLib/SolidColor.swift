//
//  SolidColor.swift
//  
//
//  Created by Danielle Kefford on 12/20/22.
//

public struct SolidColor: Material {
    var color: Color
    public var properties = MaterialProperties()

    public static let white = SolidColor(1.0, 1.0, 1.0)
    public static let black = SolidColor(0.0, 0.0, 0.0)

    public init(_ r: Double, _ g: Double, _ b: Double, properties: MaterialProperties = MaterialProperties()) {
        self.color = Color(r, g, b)
    }

    public func colorAt(_ object: Shape, _ worldPoint: Point) -> Color {
        return color
    }

    public func copy() -> SolidColor {
        SolidColor(self.color.r, self.color.g, self.color.b, properties: self.properties)
    }
}
