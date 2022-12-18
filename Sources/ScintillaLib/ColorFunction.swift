//
//  File.swift
//  
//
//  Created by Danielle Kefford on 12/17/22.
//

public typealias ColorFunctionType = (Double, Double, Double) -> (Double, Double, Double)

public struct ColorFunction {
    var transform: Matrix4
    var inverseTransform: Matrix4
    var colorFunction: ColorFunctionType

    public init(_ colorFunction: @escaping ColorFunctionType) {
        self.colorFunction = colorFunction
        self.transform = .identity
        self.inverseTransform = transform.inverse()
    }

    public func transform(_ transform: Matrix4) -> Self {
        var copy = self
        copy.transform = transform
        copy.inverseTransform = transform.inverse()
        return copy
    }

    func colorAt( _ object: Shape, _ worldPoint: Point) -> Color {
        let objectPoint = object.inverseTransform.multiply(worldPoint)
        let colorFunctionPoint = self.inverseTransform.multiply(objectPoint)
        return self.colorAt(colorFunctionPoint)
    }

    func colorAt(_ point: Tuple4) -> Color {
        let (r, g, b) = colorFunction(point.x, point.y, point.z)
        return Color(r, g, b)
    }
}
