//
//  AVAsset.swift
//

import AVFoundation

public extension AVAsset {
    /**
     Блок вызываемый по завершении.
     */
    typealias Completion = (_ error: Error?) -> Void
    
    /**
     Проверить поток.
     
     Загружает и тестирует ключи
     [isPlayable](https://developer.apple.com/documentation/avfoundation/avasset/1385974-isplayable) и
     [hasProtectedContent](https://developer.apple.com/documentation/avfoundation/avasset/1389223-hasprotectedcontent).
     
     [AVPlayerItem](https://developer.apple.com/documentation/avfoundation/avplayeritem)
     необходимо инициацизировать, если значение `isPlayable` равно `true`.
     Однако значение `true` не является достаточным условием.
     
     Если значение `hasProtectedContent` равно `true`, то это значит,
     что поток содержит защищенный контент.
     Кроме того, если значение `hasProtectedContent` не удалось загрузить,
     то это также означает, что поток недоступен для проигрывания.
     
     Источник:
     [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
     - Parameters:
        - completion: Блок, вызываемый после проверки потока. Вызывается в главном потоке. Ничего не возвращает и принимает ошибку:
            - error: Ошибка, если поток недоступен для проигрывания
     
     Пример:
     ``` swift
     let asset = AVAsset(url: URL_OF_ASSET)
     asset.validate { error in
         if let error {
            print(error)
         }
     }
     ```
     */
    func validate(completion: @escaping Completion) {
        let assetKeysRequiredToPlay = [
            #keyPath(AVAsset.isPlayable),
            #keyPath(AVAsset.hasProtectedContent)
        ]
        // Держит сильную ссылку на себя до завершения запроса.
        self.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                self.validateValues(forKeys: assetKeysRequiredToPlay, completion)
            }
        }
    }
    /**
     Подтвердить успешную загрузку ключей и проверить их значение.
     - Parameter keys: Список ключей для проверки.
     - Parameter completion: Блок, вызываемый после проверки потока.
     */
    private func validateValues(forKeys keys: [String], _ completion: @escaping Completion) {
        for key in keys {
            var error: NSError?
            if self.statusOfValue(forKey: key, error: &error) == .failed {
                completion(error)
                return
            }
        }
        
        let error: AVAssetError?
        if !self.isPlayable {
            error = .isNotPlayable
        } else if self.hasProtectedContent {
            error = .hasProtectedContent
        } else {
            error = nil
        }
        completion(error)
    }
    
    
}
