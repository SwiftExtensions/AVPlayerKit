//
//  AVPictureInPictureControllerDelegateProxy.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 17.10.2025.
//

import AVKit

/**
 Прокси для обработки событий делегата `AVPictureInPictureController` и их ретрансляции подписчикам.
 */
public class AVPictureInPictureControllerDelegateProxy: NSObject {
    /**
     Ассоциативное хранилище делегатов с использованием слабых ссылок.
     */
    typealias Delegates = [ObjectIdentifier : WeakRef<AnyObject>]
    
    /**
     Источник данных, обеспечивающий восстановление интерфейса после выхода из режима «картинка в картинке».
     */
    public weak var dataSource: AVPictureInPictureControllerDataSource?
    
    /**
     Зарегистрированные делегаты, удерживаемые как слабые ссылки.
     */
    private var delegates: Delegates = [:]
    
    /**
     Добавляет делегата для получения событий режима «картинка в картинке».
     - Parameter delegate: Объект, реализующий `AVPictureInPictureControllerEventDelegate`.
     */
    public func setDelegate(_ delegate: AVPictureInPictureControllerEventDelegate) {
        self.delegates.updateValue(WeakRef(delegate), forKey: ObjectIdentifier(delegate))
    }
    /**
     Удаляет делегата из списка получателей событий.
     - Parameter delegate: Объект, ранее зарегистрированный как делегат.
     */
    public func removeDelegate(_ delegate: AVPictureInPictureControllerEventDelegate) {
        self.delegates.removeValue(forKey: ObjectIdentifier(delegate))
    }
    
    
}

// MARK: - AVPictureInPictureControllerDelegate

extension AVPictureInPictureControllerDelegateProxy: AVPictureInPictureControllerDelegate {
    /**
     Запрашивает у источника данных восстановление интерфейса после завершения режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     - Parameter completionHandler: Замыкание, завершающее восстановление интерфейса.
     */
    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
//        print("\(Self.self).\(#function).\(#line)")
        guard let dataSource else {
            completionHandler(true)
            return
        }
        
        dataSource.pictureInPictureController(
            pictureInPictureController,
            restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler
        )
    }
    /**
     Рассылает событие всем зарегистрированным делегатам.
     - Parameter event: Событие жизненного цикла режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер, инициировавший событие.
     */
    private func handleEvent(
        _ event: AVPictureInPictureController.Event,
        of pictureInPictureController: AVPictureInPictureController
    ) {
        for (key, delegate) in self.delegates {
            guard let delegate = delegate.object else {
                self.delegates.removeValue(forKey: key)
                continue
            }
            if let delegate = delegate as? AVPictureInPictureControllerEventDelegate {
                delegate.pictureInPictureController(pictureInPictureController, event: event)
            }
        }
    }
    /**
     Делегирует событие начала подготовки режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     */
    public func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
//        print("\(Self.self).\(#function).\(#line)")
        self.handleEvent(.willStart, of: pictureInPictureController)
    }
    /**
     Делегирует событие успешного запуска режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     */
    public func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
//        print("\(Self.self).\(#function).\(#line)")
        self.handleEvent(.didStart, of: pictureInPictureController)
    }
    /**
     Делегирует событие сбоя запуска режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     - Parameter error: Ошибка, описывающая причину сбоя.
     */
    public func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: any Error
    ) {
//        print("\(Self.self).\(#function).\(#line) \(error)")
        self.handleEvent(.failedToStart(error), of: pictureInPictureController)
    }
    /**
     Делегирует событие начала завершения режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     */
    public func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
//        print("\(Self.self).\(#function).\(#line)")
        self.handleEvent(.willStop, of: pictureInPictureController)
    }
    /**
     Делегирует событие успешного завершения режима «картинка в картинке».
     - Parameter pictureInPictureController: Контроллер режима «картинка в картинке».
     */
    public func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
//        print("\(Self.self).\(#function).\(#line)")
        self.handleEvent(.didStop, of: pictureInPictureController)
    }
    
    
}
