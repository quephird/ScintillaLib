//
//  File.swift
//  
//
//  Created by Danielle Kefford on 12/17/22.
//

import Foundation

public typealias ColorFunctionType = (Double, Double, Double) -> (Double, Double, Double)

public struct ColorFunction: Material, Equatable {
    public var id: UUID = UUID()
    public var transform: Matrix4 = .identity {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }
    public var inverseTransform: Matrix4 = .identity
    public var inverseTransposeTransform: Matrix4 = .identity

    var colorFunction: ColorFunctionType
    var colorSpace: ColorSpace
    public var properties = MaterialProperties()

    public init(_ colorSpace: ColorSpace = .rgb, _ colorFunction: @escaping ColorFunctionType) {
        self.colorFunction = colorFunction
        self.transform = .identity
        self.inverseTransform = transform.inverse()
        self.colorSpace = colorSpace
    }

    public static func == (lhs: ColorFunction, rhs: ColorFunction) -> Bool {
        return lhs.id == rhs.id
    }

    public func copy() -> ColorFunction {
        var copy = ColorFunction(self.colorSpace, self.colorFunction)
        copy.transform = self.transform
        copy.inverseTransform = self.inverseTransform
        copy.properties = self.properties
        return copy
    }

    public func transform(_ transform: Matrix4) -> Self {
        var copy = self
        copy.transform = transform
        copy.inverseTransform = transform.inverse()
        return copy
    }

    public func colorAt( _ object: any Shape, _ worldPoint: Point) -> Color {
        let objectPoint = object.inverseTransform.multiply(worldPoint)
        let colorFunctionPoint = self.inverseTransform.multiply(objectPoint)
        return self.colorAt(colorFunctionPoint)
    }

    public func colorAt(_ point: Tuple4) -> Color {
        let (component1, component2, component3) = colorFunction(point.x, point.y, point.z)
        return colorSpace.makeColor(component1, component2, component3)
    }
}
