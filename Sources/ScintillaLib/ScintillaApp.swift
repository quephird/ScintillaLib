//
//  File.swift
//  
//
//  Created by Danielle Kefford on 9/24/22.
//

//import Foundation
//import Cocoa
//
//public protocol ScintillaApp {
//    @WorldBuilder var body: World { get }
//
//    init()
//}
//
//extension ScintillaApp {
//    public static func main() {
//        let instance = Self()
//        let instanceBody = instance.body
//        let canvas = instanceBody.render()
//        let outputFilename = String(describing: self) + ".png"
//        canvas.save(to: outputFilename)
//    }
//}

import SwiftUI

@available(macOS 11.0, *)
public protocol ScintillaApp: App {
    @WorldBuilder var world: World { get }
}

//@available(macOS 11.0, *)
//extension ScintillaApp {
//    var body: some Scene {
//        WindowGroup {
//            ScintillaView(world: world)
//                .onDisappear {
//                    exit(0)
//                }
//        }
//    }
//}
