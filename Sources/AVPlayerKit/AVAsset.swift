//
//  AVAsset.swift
//

import AVFoundation

public extension AVAsset {
    /**
     Проверить поток.
     
     Загружает и тестирует ключи  `playable` и `hasProtectedContent`.
     
     [AVPlayerItem](https://developer.apple.com/documentation/avfoundation/avplayeritem)
     необходимо инициацизировать, если значение `playable` равно `true`.
     Однако значение `true` не необходимое, но не достаточное условие для проверки.
     
     Если значение `hasProtectedContent` равно `true`, то это значит,
     что поток содержит защищенный контент.
     Кроме того, если значение `hasProtectedContent` не удалось загрузить,
     то это также означает, что поток не доступен для проигрывания.
     
     Источник: [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
     - Parameter completionHandler: Блок, вызываемый после проверки потока.
     */
    func validate(completionHandler: @escaping (Error?) -> Void) {
        let assetKeysRequiredToPlay = [
            #keyPath(AVAsset.isPlayable),
            #keyPath(AVAsset.hasProtectedContent)
        ]
        self.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                self.validateValues(forKeys: assetKeysRequiredToPlay, completionHandler)
            }
        }
    }
    /**
     Подтвердить успешную загрузку ключей и проверить их значение.
     - Parameter keys: Список ключей для проверки.
     - Parameter completionHandler: Блок, вызываемый после проверки потока.
     */
    private func validateValues(forKeys keys: [String], _ completionHandler: @escaping (Error?) -> Void) {
        for key in keys {
            var error: NSError?
            if self.statusOfValue(forKey: key, error: &error) == .failed {
                completionHandler(error)
                return
            }
        }
        
        let error: Error?
        if !self.isPlayable {
            error = AVAssetError.isNotPlayable
        } else if self.hasProtectedContent {
            error = AVAssetError.hasProtectedContent
        } else {
            error = nil
        }
        completionHandler(error)
    }
    
    
}
