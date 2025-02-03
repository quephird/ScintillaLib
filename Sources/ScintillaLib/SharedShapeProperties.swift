//
//  SharedShapeProperties.swift
//
//
//  Created by Danielle Kefford on 11/29/23.
//

import Foundation

public typealias ShapeID = [UInt8]

public struct SharedShapeProperties {
    public init() {
        self.inverseTransform = transform.inverse()
        self.inverseTransposeTransform = transform.inverse().transpose()
    }

    @_spi(Testing) public var id: ShapeID = []
    public var parentID: ShapeID? {
        if self.id.count == 1 {
            return nil
        }

        return self.id.dropLast()
    }

    public private(set) var inverseTransform: Matrix4
    public private(set) var inverseTransposeTransform: Matrix4
    public var transform: Matrix4 = .identity {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }

    public var material: Material = .basicMaterial()
    public var castsShadow: Bool = true
}
