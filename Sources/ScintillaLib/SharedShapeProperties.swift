//
//  SharedShapeProperties.swift
//
//
//  Created by Danielle Kefford on 11/29/23.
//

import Foundation

public struct SharedShapeProperties {
    public init() {
        self.inverseTransform = transform.inverse()
        self.inverseTransposeTransform = transform.inverse().transpose()
    }

    public var transform: Matrix4 = .identity {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }

    public private(set) var inverseTransform: Matrix4
    public private(set) var inverseTransposeTransform: Matrix4

    @_spi(Testing) public var id: UUID = UUID()
    public var material: Material = .basicMaterial()

    public var castsShadow: Bool = true
}
