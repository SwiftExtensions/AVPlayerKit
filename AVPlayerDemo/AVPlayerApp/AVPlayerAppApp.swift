//
//  AVPlayerAppApp.swift
//  AVPlayerApp
//
//  Created by Александр Алгашев on 11.12.2025.
//

import SwiftUI
import AVFoundation

@main
struct AVPlayerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                player: AVPlayer(url: Constant.stream.url)
            )
        }
    }
}

