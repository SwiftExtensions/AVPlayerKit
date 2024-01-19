//
//  PlayerViewController.swift
//

import UIKit
import AVFoundation

/**
 Контроллер представления в качестве представления которого используется ``PlayerView``.
 */
open class PlayerViewController: UIViewController {
    /**
     Подкласс
     [UIView](https://developer.apple.com/documentation/uikit/uiview)
     поддерживаемый слоем
     [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer).
     
     Дополнительную информацию см.:
     [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
     */
    public private(set) weak var playerView: PlayerView!
    
    private var playerToken: NSKeyValueObservation?
    private var playerObserver: NSObjectObserver<AVPlayer>?
    private var playerItemObserver: NSObjectObserver<AVPlayerItem>?
    /**
     Наблюдатель зависаний плеера.
     */
    private var playerStallsObserver: PlayerStallsObserver!
    
    /**
     Создает ``PlayerView`` которым будет управлять контроллер.
     */
    open override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .black
        
        let playerView = PlayerView(frame: self.view.bounds)
        self.playerView = playerView
        self.view.addSubview(playerView)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerToken = self.playerView.observe(\.player) { [unowned self] playerView, _ in
            if let player = playerView.player {
                self.handlePlayerUpdate(player: player)
            } else {
                self.playerItemObserver?.invalidate()
                self.playerItemObserver = nil
                self.playerObserver?.invalidate()
                self.playerObserver = nil
                self.playerStallsObserver = nil
            }
        }
    }
    
    private func handlePlayerUpdate(player: AVPlayer) {
        let playerObserver = NSObjectObserver(object: player)
        self.playerObserver = playerObserver
        self.startPlayerStatusObserving(observer: playerObserver)
        self.startExternalPlaybackObserving(observer: playerObserver)
        if let playerItem = player.currentItem {
            self.startPlayerItemStatusObserving(playerItem: playerItem)
        } else {
            self.startPlayerItemObserving(observer: playerObserver)
        }
        self.startPlayerStallsObserving(player: player)
    }
    
    private func startPlayerStatusObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.status) { [unowned self] player, _ in
            if player.status == .failed {
                let message = player.error?.localizedDescription ?? "Неизвестная ошибка."
                self.showPlayerInfo(message)
            } else {
                self.hidePlayerInfo()
            }
        }
    }
    
    private func startExternalPlaybackObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.isExternalPlaybackActive) { [unowned self] player, _ in
            self.handleExternalPlaybackStateUpdate(
                isExternalPlaybackActive: player.isExternalPlaybackActive
            )
        }
    }
    
    private func handleExternalPlaybackStateUpdate(isExternalPlaybackActive: Bool) {
        if isExternalPlaybackActive {
            let route = AVAudioSession.sharedInstance().currentRoute
            let deviceName = route.outputs.first?.portName ?? "(не определено)"
            let message = "Идет трансляция на внешнем устройстройстве: \(deviceName)."
            self.showPlayerInfo(message)
        } else {
            self.hidePlayerInfo()
        }
    }
    
    private func startPlayerItemObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.currentItem) { [unowned self] player, _ in
            if let playerItem = player.currentItem {
                self.startPlayerItemStatusObserving(playerItem: playerItem)
            } else {
                self.playerItemObserver?.invalidate()
                self.playerItemObserver = nil
            }
        }
    }
    
    private func startPlayerItemStatusObserving(playerItem: AVPlayerItem) {
        self.playerItemObserver = NSObjectObserver(object: playerItem)
        self.playerItemObserver?.startObserving(\.status) { [unowned self] playerItem, _ in
            if playerItem.status == .failed {
                let message = playerItem.error?.localizedDescription ?? "Неизвестная ошибка"
                self.showPlayerInfo(message)
            } else {
                self.hidePlayerInfo()
            }
        }
    }
    
    private func showPlayerInfo(_ message: String) {
        self.playerView.infoLabel.text = message
        self.playerView.infoLabel.isHidden = false
    }
    
    private func hidePlayerInfo() {
        self.playerView.infoLabel.text = nil
        self.playerView.infoLabel.isHidden = true
    }
    
    private func startPlayerStallsObserving(player: AVPlayer) {
        self.playerStallsObserver = PlayerStallsObserver()
        self.playerStallsObserver.startObserving(player: player) { [unowned self] isStalled in
            self.handlePlayerStallStateUpdate(isStalled)
        }
    }
    
    private func handlePlayerStallStateUpdate(_ isStalled: Bool) {
        if isStalled {
            self.playerView.loadingIndicator.startAnimating()
        } else {
            self.playerView.loadingIndicator.stopAnimating()
        }
    }
    
    deinit {
        self.playerObserver?.invalidate()
        self.playerToken?.invalidate()
    }
    
    
}

