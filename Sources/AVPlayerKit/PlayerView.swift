//
//  PlayerView.swift
//  

import UIKit
import AVFoundation

/**
 Подкласс
 [UIView](https://developer.apple.com/documentation/uikit/uiview)
 поддерживаемый слоем
 [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer).
 
 Дополнительную информацию см.:
 [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
 */
open class PlayerView: UIView {
    public var player: AVPlayer? {
        get { self.playerLayer.player }
        set { self.playerLayer.player = newValue }
    }

    public var playerLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer
    }

    public override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    
}
