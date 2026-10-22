//
//  PlaybackErrorDelegate.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 22.10.2026.
//

import AVFoundation

public extension PlayerViewController {
    /**
     Делегат ошибок воспроизведения.
     */
    protocol PlaybackErrorDelegate: AnyObject {
        /**
         Сообщает об ошибке плеера.
         - Parameter playerViewController: Контроллер, сообщивший об ошибке.
         - Parameter player: Плеер, сообщивший об ошибке.
         - Parameter error: Ошибка воспроизведения. `nil`, если система не сообщила причину.
         */
        func playerViewController(
            _ playerViewController: PlayerViewController,
            player: AVPlayer,
            didFailWith error: (any Error)?
        )
        /**
         Сообщает об ошибке элемента воспроизведения.
         - Parameter playerViewController: Контроллер, сообщивший об ошибке.
         - Parameter playerItem: Элемент воспроизведения, сообщивший об ошибке.
         - Parameter error: Ошибка воспроизведения. `nil`, если система не сообщила причину.
         */
        func playerViewController(
            _ playerViewController: PlayerViewController,
            playerItem: AVPlayerItem,
            didFailWith error: (any Error)?
        )
        
        
    }
    
    
}
