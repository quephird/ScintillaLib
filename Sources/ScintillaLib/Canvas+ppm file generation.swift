//
//  Ppm.swift
//  Scintilla
//
//  Created by Danielle Kefford on 11/20/21.
//

import Foundation
import CoreImage

let MAX_PPM_LINE_WIDTH = 70

public extension Canvas {
    internal func ppmHeader() -> String {
        "P3\n\(width) \(height)\n255"
    }

    internal func line(_ y: Int) -> String {
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

    internal func body() -> String {
        var body = ""
        for y in 0...self.height-1 {
            body.append(self.line(y))
        }

        return body
    }

    internal func toPPM() -> String {
        var ppm = ""
        ppm.append(self.ppmHeader())
        ppm.append("\n")
        ppm.append(self.body())
        return ppm
    }

    func save(to fileName: String) {
        let filePath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            try self.toPPM().write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Could not save to file")
        }
    }

    func toCGImage() -> CGImage {
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
}
