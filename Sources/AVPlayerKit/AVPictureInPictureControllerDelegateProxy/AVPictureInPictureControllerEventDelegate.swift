//
//  AVPictureInPictureControllerEventDelegate.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 20.10.2025.
//

import AVKit

/**
 Описывает обработчик событий режима «картинка в картинке».
 */
public protocol AVPictureInPictureControllerEventDelegate: AnyObject {
    /**
     Делегирует событие режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     - Parameter event: Событие жизненного цикла режима «картинка в картинке».
     */
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        event: AVPictureInPictureController.Event
    )
    
    
}
