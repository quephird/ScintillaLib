//
//  Ppm.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/20/21.
//

import Foundation
import Cocoa

let MAX_PPM_LINE_WIDTH = 70

public extension Canvas {
    @_spi(Testing) func ppmHeader() -> String {
        "P3\n\(width) \(height)\n255"
    }

    @_spi(Testing) func line(_ y: Int) -> String {
        var characterCount = 0
        var line = ""
        for x in 0...self.width-1 {
            let (r, g, b) = self.getPixel(x, y).toPpm()
            var temp = "\(r) \(g) \(b)"
            if characterCount + temp.count <= MAX_PPM_LINE_WIDTH {
                line.append(temp)
                characterCount += temp.count
            } else {
                temp = "\(r) \(g)"
                if characterCount + temp.count <= MAX_PPM_LINE_WIDTH {
                    line.append(temp)
                    line.append("\n")
                    temp = "\(b)"
                    line.append(temp)
                    characterCount = temp.count
                } else {
                    temp = "\(r)"
                    if characterCount + temp.count <= MAX_PPM_LINE_WIDTH {
                        line.append(temp)
                        line.append("\n")
                        temp = "\(g) \(b)"
                        line.append(temp)
                        characterCount = temp.count
                    } else {
                        line.append("\n")
                        temp = "\(r) \(g) \(b)"
                        line.append(temp)
                        characterCount = temp.count
                    }
                }
            }

            if x != self.width-1 && characterCount < 69 {
                line.append(" ")
                characterCount += 1
            } else {
                line.append("\n")
            }
        }

        return line
    }

    @_spi(Testing) func body() -> String {
        var body = ""
        for y in 0...self.height-1 {
            body.append(self.line(y))
        }

        return body
    }

    @_spi(Testing) func toPPM() -> String {
        var ppm = ""
        ppm.append(self.ppmHeader())
        ppm.append("\n")
        ppm.append(self.body())
        return ppm
    }

    func toCGImage() -> CGImage {
        // Adapted from https://stackoverflow.com/questions/30958427/pixel-array-to-uiimage-in-swift
        let height = self.height
        let width = self.width
        let numComponents = 3
        let numBytes = height * width * numComponents
        let pixelData = self.pixels.flatMap { color in
            color.toBytes()
        }
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let rgbData = CFDataCreate(nil, pixelData, numBytes)!
        let provider = CGDataProvider(data: rgbData)!
        let cgImage = CGImage(width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bitsPerPixel: 8 * numComponents,
                              bytesPerRow: width * numComponents,
                              space: colorspace,
                              bitmapInfo: CGBitmapInfo(rawValue: 0),
                              provider: provider,
                              decode: nil,
                              shouldInterpolate: true,
                              intent: CGColorRenderingIntent.defaultIntent)!
        return cgImage
    }

    func toNSImage() -> NSImage {
        let cgImage = self.toCGImage()
        return NSImage(cgImage: cgImage, size: .init(width: self.width, height: self.height))
    }

    func save(to fileName: String) {
        // Adapted from https://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
        let cgImage = self.toCGImage()
        let ciContext = CIContext()
        let ciImage = CIImage(cgImage: cgImage)

        do {
            let desktopDirectoryUrl = try FileManager.default.url(
                for: .desktopDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            let fileUrl = desktopDirectoryUrl.appendingPathComponent(fileName)

            try ciContext.writePNGRepresentation(
                of: ciImage,
                to: fileUrl,
                format: .RGBA8,
                colorSpace: ciImage.colorSpace!)
        } catch {
            // TODO: Need better error handling here
            print(error)
        }
    }
}
