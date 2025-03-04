//
//  Pattern.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

open class Pattern: Material, Equatable {
    public var transform: Matrix4 = .identity {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }
    public var inverseTransform: Matrix4
    public var inverseTransposeTransform: Matrix4
    public var properties = MaterialProperties()

    public init(_ transform: Matrix4, _ properties: MaterialProperties) {
        self.transform = transform
        self.inverseTransform = transform.inverse()
        self.inverseTransposeTransform = transform.inverse().transpose()
    }

    public static func == (lhs: Pattern, rhs: Pattern) -> Bool {
        return lhs === rhs
    }

    open func copy() -> Self {
        fatalError("Subclasses must override this method!")
    }

    public func colorAt( _ object: any Shape, _ worldPoint: Point) -> Color {
        let objectPoint = object.inverseTransform.multiply(worldPoint)
        let patternPoint = self.inverseTransform.multiply(objectPoint)
        return self.colorAt(patternPoint)
    }

    open func colorAt(_ point: Tuple4) -> Color {
        fatalError("Subclasses must override this method!")
    }
}

final public class Striped: Pattern {
    var firstColor: Color
    var secondColor: Color

    public init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4, properties: MaterialProperties = MaterialProperties()) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform, properties)
    }

    public override func copy() -> Self {
        return .init(firstColor, secondColor, transform, properties: properties)
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

final public class Checkered2D: Pattern {
    var firstColor: Color
    var secondColor: Color

    public init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4, properties: MaterialProperties = MaterialProperties()) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform, properties)
    }

    public override func copy() -> Self {
        return .init(firstColor, secondColor, transform, properties: properties)
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0]) + floor(patternPoint[2])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

final public class Checkered3D: Pattern {
    var firstColor: Color
    var secondColor: Color

    public init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4, properties: MaterialProperties = MaterialProperties()) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform, properties)
    }

    public override func copy() -> Self {
        return .init(firstColor, secondColor, transform, properties: properties)
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0]) + floor(patternPoint[1]) + floor(patternPoint[2])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

final public class Gradient: Pattern {
    var firstColor: Color
    var secondColor: Color

    public init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4, properties: MaterialProperties = MaterialProperties()) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform, properties)
    }

    public override func copy() -> Self {
        return .init(firstColor, secondColor, transform, properties: properties)
    }

    public override func colorAt(_ patternPoint: Tuple4) -> Color {
        return firstColor.add(secondColor.subtract(firstColor).multiplyScalar(patternPoint[0] - floor(patternPoint[0])))
    }
}
