//
//  Shape.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/22/21.
//

import Foundation

public class Shape {
    static var latestId: Int = 0
    @_spi(Testing) public var id: Int
    var transform: Matrix4 {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }
    var material: Material = .basicMaterial()
    var inverseTransform: Matrix4
    var inverseTransposeTransform: Matrix4
    var parent: Container?
    var castsShadow: Bool

    public init() {
        self.id = Self.latestId
        self.transform = .identity
        self.inverseTransform = transform.inverse()
        self.inverseTransposeTransform = transform.inverse().transpose()
        self.castsShadow = true
        Self.latestId += 1
    }

    public func union(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.union, self, otherShapesBuilder)
    }

    public func difference(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.difference, self, otherShapesBuilder)
    }

    public func intersection(@ShapeBuilder _ otherShapesBuilder: () -> [Shape]) -> Shape {
        return CSG.makeCSG(.intersection, self, otherShapesBuilder)
    }

    public func material(_ material: Material) -> Self {
        self.material = material

        return self
    }

    public func castsShadow(_ castsShadow: Bool) -> Self {
        self.castsShadow = castsShadow

        return self
    }

    public func translate(_ x: Double, _ y: Double, _ z: Double) -> Self {
        self.transform = .translation(x, y, z)
            .multiply(self.transform)

        return self
    }

    public func scale(_ x: Double, _ y: Double, _ z: Double) -> Self {
        self.transform = .scaling(x, y, z)
            .multiply(self.transform)

        return self
    }

    public func rotateX(_ t: Double) -> Self {
        self.transform = .rotationX(t)
            .multiply(self.transform)

        return self
    }

    public func rotateY(_ t: Double) -> Self {
        self.transform = .rotationY(t)
            .multiply(self.transform)

        return self
    }

    public func rotateZ(_ t: Double) -> Self {
        self.transform = .rotationZ(t)
            .multiply(self.transform)

        return self
    }

    public func shear(_ xy: Double, _ xz: Double, _ yx: Double, _ yz: Double, _ zx: Double, _ zy: Double) -> Self {
        self.transform = .shearing(xy, xz, yx, yz, zx, zy)
            .multiply(self.transform)

        return self
    }

    func intersect(_ worldRay: Ray) -> [Intersection] {
        let localRay = worldRay.transform(self.inverseTransform)
        return self.localIntersect(localRay)
    }

    func localIntersect(_ localRay: Ray) -> [Intersection] {
        fatalError("Subclasses must override this method!")
    }

    func normal(_ worldPoint: Point) -> Vector {
        let localPoint = self.worldToObject(worldPoint)
        let localNormal = self.localNormal(localPoint)
        return self.objectToWorld(localNormal)
    }

    func localNormal(_ localPoint: Point) -> Vector {
        fatalError("Subclasses must override this method!")
    }

    func worldToObject(_ worldPoint: Point) -> Point {
        var objectPoint = worldPoint
        if case .group(let group) = parent {
            objectPoint = group.worldToObject(worldPoint)
        } else if case .csg(let csg) = parent {
            objectPoint = csg.worldToObject(worldPoint)
        }
        return self.inverseTransform.multiply(objectPoint)
    }

    func objectToWorld(_ objectNormal: Vector) -> Vector {
        var worldNormal = self.inverseTransposeTransform.multiply(objectNormal)
        worldNormal[3] = 0
        worldNormal = worldNormal.normalize()

        if case .group(let group) = parent {
            worldNormal = group.objectToWorld(worldNormal)
        } else if case .csg(let csg) = parent {
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
