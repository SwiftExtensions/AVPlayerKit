//
//  ContentView.swift
//  AVPlayerApp
//
//  Created by Александр Алгашев on 11.12.2025.
//

import AVFoundation
import AVPlayerUI
import SwiftUI

struct ContentView: View {
    let player: AVPlayer
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            PlayerViewRepresentable(player: player)
                .ignoresSafeArea()
            playbackButton
        }
    }
    
    private var playbackButton: some View {
        Button {
            isPlaying.toggle()
            if isPlaying {
                player.play()
            } else {
                player.pause()
            }
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .padding(20)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
        }
    }
}

struct PlayerViewRepresentable: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerView {
        let playerView = PlayerView(frame: .zero)
        playerView.player = player
        return playerView
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
    }
}

#Preview {
    ContentView(player: AVPlayer(url: Constant.stream.url))
}
