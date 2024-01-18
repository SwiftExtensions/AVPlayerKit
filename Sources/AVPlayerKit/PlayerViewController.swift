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
                self.startPlayerStallsObserving(player: player)
            } else {
                self.playerStallsObserver = nil
            }
        }
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
        self.playerToken?.invalidate()
    }
    
    
}

