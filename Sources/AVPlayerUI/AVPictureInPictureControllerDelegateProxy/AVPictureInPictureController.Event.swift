//
//  AVPictureInPictureController.Event.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 20.10.2025.
//

import AVKit

public extension AVPictureInPictureController {
    /**
     Событие жизненного цикла режима «картинка в картинке».
     */
    enum Event {
        /**
         Событие перед началом воспроизведения в режиме «картинка в картинке».
         */
        case willStart
        /**
         Событие успешного запуска режима «картинка в картинке».
         */
        case didStart
        /**
         Событие неудачного запуска режима «картинка в картинке».
         - Parameter error: Ошибка, описывающая причину сбоя.
         */
        case failedToStart(_ error: Error)
        /**
         Событие перед остановкой режима «картинка в картинке».
         */
        case willStop
        /**
         Событие успешного завершения режима «картинка в картинке».
         */
        case didStop
        
        
    }
    
    
}
