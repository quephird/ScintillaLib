//
//  ScintillaView.swift
//
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI

@MainActor public struct ScintillaView: View {
    @State private var nsImage: NSImage?
    @State var percentRendered: Double = 0.0
    @State var elapsedTime: Range<Date> = Date()..<Date()

    @WorldBuilder var world: World
    var fileName: String

    public init(world: World, fileName: String) {
        self.world = world
        self.fileName = fileName
    }

    public var body: some View {
        VStack {
            if let nsImage = self.nsImage {
                Spacer()
                Image(nsImage: nsImage)
                Spacer()
            } else {
                VStack {
                    Spacer()
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
                    Spacer()
                }
            }
            HStack {
                Text("Elapsed time: \(elapsedTime.formatted(.components(style: .condensedAbbreviated)))")
                    .padding(.leading, 5)
                    .padding(.bottom, 5)
                Spacer()
            }
        }.task {
            await self.renderImage()
        }
    }

    func updateProgress(_ newPercentRendered: Double, newElapsedTime: Range<Date>) {
        self.percentRendered = newPercentRendered
        self.elapsedTime = newElapsedTime
    }

    func renderImage() async {
        do {
            let canvas = try await world.render(updateClosure: updateProgress)
            self.nsImage = canvas.toNSImage()
            canvas.save(to: self.fileName)
        } catch is CancellationError {
            // Do nothing!
        } catch {
            fatalError("Whoops! Something _really_ bad happened: \(error)")
        }
    }
}
