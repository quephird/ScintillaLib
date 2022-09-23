//
//  Pattern.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/24/21.
//

import Foundation

class Pattern {
    var transform: Matrix4
    var inverseTransform: Matrix4

    init(_ transform: Matrix4) {
        self.transform = transform
        self.inverseTransform = transform.inverse()
    }

    func colorAt( _ object: Shape, _ worldPoint: Tuple4) -> Color {
        let objectPoint = object.inverseTransform.multiplyTuple(worldPoint)
        let patternPoint = self.inverseTransform.multiplyTuple(objectPoint)
        return self.colorAt(patternPoint)
    }

    func colorAt(_ point: Tuple4) -> Color {
        fatalError("Subclasses must override this method!")
    }
}

class Striped: Pattern {
    var firstColor: Color
    var secondColor: Color

    init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform)
    }

    override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

class Checkered2D: Pattern {
    var firstColor: Color
    var secondColor: Color

    init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform)
    }

    override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0]) + floor(patternPoint[2])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

class Checkered3D: Pattern {
    var firstColor: Color
    var secondColor: Color

    init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform)
    }

    override func colorAt(_ patternPoint: Tuple4) -> Color {
        if Int(floor(patternPoint[0]) + floor(patternPoint[1]) + floor(patternPoint[2])) % 2 == 0 {
            return firstColor
        } else {
            return secondColor
        }
    }
}

class Gradient: Pattern {
    var firstColor: Color
    var secondColor: Color

    init(_ firstColor: Color, _ secondColor: Color, _ transform: Matrix4) {
        self.firstColor = firstColor
        self.secondColor = secondColor
        super.init(transform)
    }

    override func colorAt(_ patternPoint: Tuple4) -> Color {
        return firstColor.add(secondColor.subtract(firstColor).multiplyScalar(patternPoint[0] - floor(patternPoint[0])))
    }
}
