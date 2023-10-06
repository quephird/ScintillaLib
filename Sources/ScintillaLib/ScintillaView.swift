//
//  ScintillaView.swift
//
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI

@available(macOS 12.0, *)
public struct ScintillaView: View {
    @State private var nsImage: NSImage?

    @WorldBuilder var world: World

    public init(world: World) {
        self.world = world
    }

    public var body: some View {
        VStack {
            if let nsImage = self.nsImage {
                Image(nsImage: nsImage)
            } else {
                Text("Rendering...")
            }
        }.task {
            await self.renderImage()
        }
    }

    func renderImage() async {
        let canvas = world.render()
        self.nsImage = canvas.toNSImage()
    }
}
