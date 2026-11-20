//
//  ViewController.swift
//  AVPlayerDemo
//
//  Created by Александр Алгашев on 26.08.2022.
//

import AVKit
import MediaPlayer
import UIKit

import AVPlayerUI
//import SFCore

final class ViewController: PlayerViewController {
    let remoteCommandCenter = RemoteCommandCenter()
    private var accessLogEntryToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableAirPlay()
        self.enablePictureInPicture()
        
        let url = Constant.stream.url
   
        self.validateAssetURL(url)
        
        let player = AVPlayer(url: url)
        self.playerView.player = player
        
        self.setupTimeControlStatusObserving()
        self.setupAccessLogEntryNotification()
        self.setupRemoteCommandCenter()
        self.setupNowPlayingInfo()
    }
   
    private func validateAssetURL(_ url: URL) {
//        let url = URL(string: "https://ya.ru")
//        let url = URL(string: "https://ya.ru/Sony_Turbo.m3u8")
        let asset = AVAsset(url: url)
        asset.validate { error in
            if let error {
                print("\(Self.self).\(#function)+\(#line) \(error)")
            }
        }
        Task {
            do {
                try await asset.validatePlayability()
            } catch {
                print("\(Self.self).\(#function)+\(#line) \(error)")
            }
        }
    }
    
    private func setupTimeControlStatusObserving() {
        self.$player.addObserver(self, keyPath: \.timeControlStatus) { player, changes in
            let message = """
                \(Self.self).\(#function)+\(#line) \
                player.timeControlStatus: \(player.timeControlStatus.customDescription)
                """
            print(message)
        }
    }
    
    private func setupAccessLogEntryNotification() {
//        let token = self.playerView.player?.currentItem?.observe(
//            \.presentationSize
//        ) { playerItem, _ in
//            
//        }
        
        self.accessLogEntryToken = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewAccessLogEntry,
            object: nil,
            queue: .main
        ) { notification in
            print(notification)
        }
    }
    
    private func setupRemoteCommandCenter() {
        self.remoteCommandCenter.addAction(to: \.playCommand) { [weak self] event in
            self?.playerView.player?.play()
            return .success
        }
        
        self.remoteCommandCenter.addAction(to: \.pauseCommand) { [weak self] event in
            guard self?.playerView.player?.timeControlStatus == .playing else {
                return .commandFailed
            }
            
            self?.playerView.player?.pause()
            return .success
        }
    }
    
    private func setupNowPlayingInfo() {
        var infoBuilder = NowPlayingInfoBuilder(
            title: "AVPlayer Demo",
            artist: Constant.stream.title
        )
        let image = UIImage(systemName: "tv")
        infoBuilder.setArtwork(image)
        infoBuilder.mediaType = .video
        infoBuilder.isLiveStream = true
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoBuilder.build()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.playerView.player?.play()
    }
    
    

}
