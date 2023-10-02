//
//  File.swift
//  
//
//  Created by Danielle Kefford on 9/24/22.
//

import Foundation
import Cocoa

public protocol ScintillaApp {
    @WorldBuilder var body: World { get }

    init()
}

extension ScintillaApp {
    public static func main() {
        let instance = Self()
        let instanceBody = instance.body
        let canvas = instanceBody.render()

        // Adapted from https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
        let cgImage = canvas.toCGImage()
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        let outputFilename = String(describing: self) + ".png"
        let fileUrl = FileManager.default.urls(
            for: .desktopDirectory,
            in: .userDomainMask).first!.appendingPathComponent(outputFilename)
        do {
            try ciContext.writePNGRepresentation(
                of: ciImage,
                to: fileUrl,
                format: .RGBA8,
                colorSpace: ciImage.colorSpace!)
        } catch {
            print(error)
        }
    }
}
