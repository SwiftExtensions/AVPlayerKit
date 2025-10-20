//
//  AVPictureInPictureControllerDataSource.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 20.10.2025.
//

import AVKit

/**
 Протокол источника данных для контроллера режима «картинка в картинке».
 
 Реализуйте этот протокол для управления восстановлением пользовательского интерфейса
 при выходе из режима «картинка в картинке».
 */
public protocol AVPictureInPictureControllerDataSource: AnyObject {
    /**
     Вызывается когда пользователь останавливает режим «картинка в картинке» и система готова восстановить интерфейс.
     
     Используйте этот метод для восстановления состояния пользовательского интерфейса приложения
     перед возвратом из режима «картинка в картинке». После завершения восстановления вызовите
     обработчик завершения с результатом операции.
     
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке», который запросил восстановление интерфейса.
     - Parameter completionHandler: Обработчик завершения, который необходимо вызвать
     после восстановления интерфейса.
     Передайте `true`, если интерфейс был успешно восстановлен, или `false` в противном случае.
     */
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    )
    
    
}
