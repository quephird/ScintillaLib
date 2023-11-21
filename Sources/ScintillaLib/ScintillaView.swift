//
//  ScintillaView.swift
//
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI

@available(macOS 12.0, *)
@MainActor public struct ScintillaView: View {
    @State private var nsImage: NSImage?
    @State var percentRendered: Double = 0.0

    @WorldBuilder var world: World
    var fileName: String

    public init(world: World, fileName: String) {
        self.world = world
        self.fileName = fileName
    }

    public var body: some View {
        VStack {
            if let nsImage = self.nsImage {
                Image(nsImage: nsImage)
            } else {
                Text(String(percentRendered))
//                Text("Rendering... (\($world.$percentRendered)% complete)")
            }
        }.task {
            await self.renderImage()
        }
    }

    func reportProgress(_ newPercentage: Double) {
        self.percentRendered = newPercentage
    }

    func renderImage() async {
        let canvas = await world.render(updateClosure: reportProgress)
        self.nsImage = canvas.toNSImage()
        canvas.save(to: self.fileName)
    }
}
