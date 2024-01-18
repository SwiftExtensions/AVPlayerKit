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
                self.playerObserver = NSObjectObserver(object: player)
                self.startPlayerStatusObserving(player: player)
                if let playerItem = player.currentItem {
                    self.startPlayerItemStatusObserving(playerItem: playerItem)
                } else {
                    self.startPlayerItemObserving(player: player)
                }
                self.startPlayerStallsObserving(player: player)
            } else {
                self.playerItemObserver?.invalidate()
                self.playerItemObserver = nil
                self.playerObserver?.invalidate()
                self.playerObserver = nil
                self.playerStallsObserver = nil
            }
        }
    }
    
    private func startPlayerStatusObserving(player: AVPlayer) {
        self.playerObserver?.startObserving(\.status) { [unowned self] player, _ in
            if player.status == .failed {
                self.showPlayerError(player.error)
            } else {
                self.hidePlayerError()
            }
        }
    }
    
    private func startPlayerItemObserving(player: AVPlayer) {
        self.playerObserver?.startObserving(\.currentItem) { [unowned self] player, _ in
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
                self.showPlayerError(playerItem.error)
            } else {
                self.hidePlayerError()
            }
        }
    }
    
    private func showPlayerError(_ error: Error?) {
        self.playerView.infoLabel.text = error?.localizedDescription ?? "Неизвестная ошибка"
        self.playerView.infoLabel.isHidden = false
    }
    
    private func hidePlayerError() {
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

