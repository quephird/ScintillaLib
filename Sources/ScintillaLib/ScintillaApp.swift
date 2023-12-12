//
//  ScintillaApp.swift
//
//
//  Created by Danielle Kefford on 9/24/22.
//

import SwiftUI

@MainActor public protocol ScintillaApp: App {
    @WorldBuilder var world: World { get }
}

public extension ScintillaApp {
    var body: some Scene {
        WindowGroup {
            ScintillaView(world: world, fileName: String(describing: Self.self) + ".png")
                .onDisappear {
                    exit(0)
                }
        }
    }
}
