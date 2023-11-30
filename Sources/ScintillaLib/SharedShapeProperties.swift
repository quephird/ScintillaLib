//
//  SharedShapeProperties.swift
//
//
//  Created by Danielle Kefford on 11/29/23.
//

import Foundation

@available(macOS 10.15, *)
public struct SharedShapeProperties {
    public init() {
        self.inverseTransform = transform.inverse()
        self.inverseTransposeTransform = transform.inverse().transpose()
    }

    @_spi(Testing) public var id: UUID = UUID()
    public var material: Material = .basicMaterial()

    public var transform: Matrix4 = .identity {
        didSet {
            self.inverseTransform = transform.inverse()
            self.inverseTransposeTransform = transform.inverse().transpose()
        }
    }

    public private(set) var inverseTransform: Matrix4
    public private(set) var inverseTransposeTransform: Matrix4
    public var parentID: UUID?
    public var castsShadow: Bool = true
}
