//
//  File.swift
//  
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI

@available(macOS 10.15, *)
public struct ScintillaView: View {
    @State private var image: Image?

    @WorldBuilder var world: World

    public init(world: World) {
        self.world = world
    }

    public var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }

    func loadImage() {
        print("Rendering...")
        let canvas = world.render()
        print("Done!!!")
        image = Image(nsImage: canvas.toNSImage())
    }
}
