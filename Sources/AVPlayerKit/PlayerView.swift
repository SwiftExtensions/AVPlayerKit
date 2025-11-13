//
//  PlayerView.swift
//  

import AVFoundation
import UIKit

/**
 Подкласс
 [UIView](https://developer.apple.com/documentation/uikit/uiview)
 поддерживаемый слоем
 [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer).
 
 ## Пример
 ```swift
 let playerView = PlayerView(frame: .zero)
 playerView.player = AVPlayer(url: videoURL)
 ```
 */
open class PlayerView: UIView {
    /**
     Плеер для отображения визуального контента представления.
     - Note: Поддерживает
     [KVO (Key-Value Observing)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift)
     для отслеживания изменений.
     */
    @objc public dynamic var player: AVPlayer? {
        get { self.playerLayer.player }
        set { self.playerLayer.player = newValue }
    }
    /**
     Слой, обеспечивающий отображение видеоконтента плеера.
     */
    public var playerLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer
    }
    /**
     Тип слоя, используемого представлением для визуализации медиаконтента.
     */
    public override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    
}
