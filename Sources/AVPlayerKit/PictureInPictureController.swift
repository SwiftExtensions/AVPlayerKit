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
@available(iOS 13.0, *)
final class PictureInPictureController: NSObject {
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
        pipController.delegate = self
        self.pipPossibleObservation = pipController.observe(
            \AVPictureInPictureController.isPictureInPicturePossible,
             options: [.initial, .new]
        ) { [weak self] _, change in
            self?.pipButton?.isEnabled = change.newValue ?? false
        }
    }
    /**
     Запускает воспроизведение в режиме PiP.
     - Parameter button: Кнопка, инициирующая переход в PiP.
     */
    @objc private func startPictureInPicture(_ button: UIButton) {
        self.pipController?.startPictureInPicture()
    }
    
    
}

// MARK: - AVPictureInPictureControllerDelegate

@available(iOS 13.0, *)
extension PictureInPictureController: AVPictureInPictureControllerDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        
    }
    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        
    }
    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        
    }
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: any Error
    ) {
        
    }
    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        
    }
    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {
        
    }
    
    
}
