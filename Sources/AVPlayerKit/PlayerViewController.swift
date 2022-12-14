//
//  PlayerViewController.swift
//

import UIKit

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
    
    
}

