//
//  File.swift
//  
//
//  Created by Danielle Kefford on 9/24/22.
//

import Foundation

public protocol ScintillaApp {
    var filename: String { get set }
    @WorldBuilder var body: (Light, Camera, [Shape]) { get }

    init()
}

extension ScintillaApp {
    public static func main() {
        let instance = Self()
        let canvas = World { return instance.body }.render()
        canvas.save(to: instance.filename)
    }
}
