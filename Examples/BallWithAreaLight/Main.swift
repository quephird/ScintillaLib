//
//  Main.swift
//  
//
//  Created by Danielle Kefford on 10/5/23.
//

import SwiftUI
import ScintillaLib

@available(macOS 11.0, *)
@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
            SwiftUIView()
                .onDisappear {
                    exit(0)
                }
        }
    }
}
