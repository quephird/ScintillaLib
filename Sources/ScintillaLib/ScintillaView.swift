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
                ProgressView(value: percentRendered) {
                    Text("Rendering…")
                } currentValueLabel: {
                    Text(
                        percentRendered
                            .formatted(
                                .percent.precision(
                                    .integerAndFractionLength(integerLimits: 1...3,
                                                              fractionLimits: 0...0))))
                }
                    .progressViewStyle(.circular)
            }
        }.task {
            await self.renderImage()
        }
    }

    func updatePercentRendered(_ newPercentRendered: Double) {
        self.percentRendered = newPercentRendered
    }

    func renderImage() async {
        let canvas = await world.render(updateClosure: updatePercentRendered)
        self.nsImage = canvas.toNSImage()
        canvas.save(to: self.fileName)
    }
}
