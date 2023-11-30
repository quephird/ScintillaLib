//
//  Shape.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public protocol Shape {
    var sharedProperties: SharedShapeProperties { get set }

    func localIntersect(_ localRay: Ray) -> [Intersection]
    func localNormal(_ localPoint: Point, _ uv: UV) -> Vector
}

extension Shape {
    @_spi(Testing) public var id: UUID {
        get { sharedProperties.id }
        set { sharedProperties.id = newValue }
    }
    public var material: Material {
        get { sharedProperties.material }
        set { sharedProperties.material = newValue }
    }
    public var transform: Matrix4 {
        get { sharedProperties.transform }
        set { sharedProperties.transform = newValue }
    }
    public var inverseTransform: Matrix4 {
        get { sharedProperties.inverseTransform }
    }
    public var inverseTransposeTransform: Matrix4 {
        get { sharedProperties.inverseTransposeTransform }
    }
    public var parentBox: ParentBox<Container>? {
        get { sharedProperties.parentBox }
        set { sharedProperties.parentBox = newValue }
    }
    public var castsShadow: Bool  {
        get { sharedProperties.castsShadow }
        set { sharedProperties.castsShadow = newValue }
    }
}

// CSG extensions
extension Shape {
    public func union(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.union, self, otherShapesBuilder)
    }

    public func difference(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.difference, self, otherShapesBuilder)
    }

    public func intersection(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.intersection, self, otherShapesBuilder)
    }
}

// Property modification extensions
extension Shape {
    public func material(_ material: Material) -> Self {
        var copy = self
        copy.material = material

        return copy
    }

    public func castsShadow(_ castsShadow: Bool) -> Self {
        var copy = self
        copy.castsShadow = castsShadow

        return copy
    }

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

// Shared implementations
extension Shape {
    @_spi(Testing) public func intersect(_ worldRay: Ray) -> [Intersection] {
        let localRay = worldRay.transform(self.inverseTransform)
        return self.localIntersect(localRay)
    }

    @_spi(Testing) public func normal(_ worldPoint: Point, _ uv: UV = .none) -> Vector {
        let localPoint = self.worldToObject(worldPoint)
        let localNormal = self.localNormal(localPoint, uv)
        return self.objectToWorld(localNormal)
    }
}

// CSG and group extensions
extension Shape {
    @_spi(Testing) public func worldToObject(_ worldPoint: Point) -> Point {
        var objectPoint = worldPoint
        if let parentBox = self.parentBox, case .group(let group) = parentBox.parent {
            objectPoint = group.worldToObject(worldPoint)
        } else if let parentBox = self.parentBox, case .csg(let csg) = parentBox.parent {
            objectPoint = csg.worldToObject(worldPoint)
        }
        return self.inverseTransform.multiply(objectPoint)
    }

    @_spi(Testing) public func objectToWorld(_ objectNormal: Vector) -> Vector {
        var worldNormal = self.inverseTransposeTransform.multiply(objectNormal)
        worldNormal[3] = 0
        worldNormal = worldNormal.normalize()

        if let parentBox = self.parentBox, case .group(let group) = parentBox.parent {
            worldNormal = group.objectToWorld(worldNormal)
        } else if let parentBox = self.parentBox, case .csg(let csg) = parentBox.parent {
            worldNormal = csg.objectToWorld(worldNormal)
        }

        return worldNormal
    }

    func includes(_ other: Shape) -> Bool {
        switch self {
        case let group as Group:
            return group.children.contains(where: {shape in shape.includes(other)})
        case let csg as CSG:
            return csg.left.includes(other) || csg.right.includes(other)
        default:
            return self.id == other.id
        }
    }
}
