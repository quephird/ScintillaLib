//
//  File.swift
//  
//
//  Created by Danielle Kefford on 9/24/22.
//

import Foundation

public protocol ScintillaApp {
    @WorldBuilder var body: World { get }

    init()
}

extension ScintillaApp {
    public static func main() {
        let instance = Self()
        let instanceBody = instance.body
        let canvas = instanceBody.render()

        let outputFilename = String(describing: self) + ".ppm"
        canvas.save(to: outputFilename)
    }
}
