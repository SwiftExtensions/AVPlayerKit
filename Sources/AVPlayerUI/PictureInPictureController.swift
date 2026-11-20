//
//  PictureInPictureController.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 14.10.2025.
//

import AVKit

/**
 Контроллер, управляющий режимом «картинка в картинке» для воспроизведения.
 */
final class PictureInPictureController: NSObject {
    /**
     Источник данных для контроллера режима «картинка в картинке».
     
     Для управления восстановлением пользовательского интерфейса
     при выходе из режима «картинка в картинке».
     */
    weak var dataSource: AVPictureInPictureControllerDataSource? {
        get { self.delegateProxy.dataSource }
        set { self.delegateProxy.dataSource = newValue }
    }
    /**
     Кнопка управления режимом «картинка в картинке».
     */
    weak var pipButton: UIButton? {
        didSet {
            self.pipButton?.addTarget(
                self,
                action: #selector(startPictureInPicture(_:)),
                for: .touchUpInside
            )
        }
    }
    /**
     Контроллер, управляющий воспроизведением в режиме PiP.
     */
    private var pipController: AVPictureInPictureController?
    /**
     Наблюдатель за свойством `isPictureInPicturePossible`.
     */
    private var pipPossibleObservation: NSKeyValueObservation?
    /**
     Наблюдатель за свойством `isPictureInPictureActive`.
     */
    private var pipActiveObservation: NSKeyValueObservation?
    /**
     Прокси для обработки событий делегата `AVPictureInPictureController` и их ретрансляции подписчикам.
     */
    private let delegateProxy = AVPictureInPictureControllerDelegateProxy()

    /**
     Подготавливает режим «картинка в картинке» для указанного слоя.
     - Parameter playerLayer: Слой воспроизведения, отображаемый в PiP.
     */
    func setupPictureInPicture(playerLayer: AVPlayerLayer) {
        var isEnabled: Bool? = false
        defer {
            isEnabled.map { self.pipButton?.isEnabled = $0 }
        }
        
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }
        
        let pipController = AVPictureInPictureController(playerLayer: playerLayer)
        guard let pipController else { return }
        
        isEnabled = nil
        self.pipController = pipController
        self.pipController?.delegate = self.delegateProxy
        self.delegateProxy.setDelegate(self)
        self.pipPossibleObservation = pipController.observe(
            \.isPictureInPicturePossible,
             options: [.initial, .new]
        ) { [weak self] pipController, _ in
            self?.pipButton?.isEnabled = pipController.isPictureInPicturePossible
        }
        
        self.pipActiveObservation = pipController.observe(
            \.isPictureInPictureActive,
            options: [.initial, .new]
        ) { [weak self] pipController, _ in
            self?.pipButton?.isHidden = pipController.isPictureInPictureActive
        }
    }
    /**
     Запускает воспроизведение в режиме PiP.
     - Parameter button: Кнопка, инициирующая переход в PiP.
     */
    @objc private func startPictureInPicture(_ button: UIButton) {
        button.isEnabled = false
        self.pipController?.startPictureInPicture()
    }
    /**
     Добавляет делегата для получения событий режима «картинка в картинке».
     - Parameter delegate: Объект, реализующий `AVPictureInPictureControllerEventDelegate`.
     */
    func setDelegate(_ delegate: AVPictureInPictureControllerEventDelegate) {
        self.delegateProxy.setDelegate(delegate)
    }
    
    
}

// MARK: - AVPictureInPictureControllerEventDelegate

extension PictureInPictureController: AVPictureInPictureControllerEventDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        event: AVPictureInPictureController.Event
    ) {
        switch event {
        case .willStart:
            break
        case .didStart:
            self.pipButton?.isEnabled = pictureInPictureController.isPictureInPicturePossible
        case .failedToStart:
            self.pipButton?.isEnabled = pictureInPictureController.isPictureInPicturePossible
        case .willStop:
            break
        case .didStop:
            break
        }
    }
    
    
}
