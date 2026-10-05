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
     Проверить возможность проигрывания ресурса.

     Асинхронно загружает ключи
     [isPlayable](https://developer.apple.com/documentation/avfoundation/avasset/1385974-isplayable) и
     [hasProtectedContent](https://developer.apple.com/documentation/avfoundation/avasset/1389223-hasprotectedcontent)
     и проверяет их значения.

     Ресурс считается непригодным для проигрывания, если значение `isPlayable`
     равно `false` или значение `hasProtectedContent` равно `true`.

     Если проверка не завершилась за время `timeout`, загрузка ключей отменяется
     и выбрасывается ошибка `URLError.timedOut`.

     - Parameter timeout: Максимальное время проверки в секундах.
       Значение `nil` означает отсутствие ограничения.
     - Throws: `AVAssetError.isNotPlayable`, если ресурс не поддерживает проигрывание.
     - Throws: `AVAssetError.hasProtectedContent`, если ресурс содержит защищенный контент.
     - Throws: `URLError.timedOut`, если проверка не завершилась за время `timeout`.
     - Throws: Ошибка загрузки, если не удалось загрузить ключи ресурса.

     Пример:
     ``` swift
     let asset = AVAsset(url: URL_OF_ASSET)
     try await asset.validatePlayability(timeout: 5.0)
     // Ресурс пригоден для проигрывания.
     ```
     */
    func validatePlayability(timeout: TimeInterval? = nil) async throws {
        guard let timeout else {
            return try await self.loadAndValidatePlayability()
        }
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadAndValidatePlayability()
            }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            try await group.next()
        }
    }
    /**
     Загрузить ключи `isPlayable` и `hasProtectedContent` и проверить их значения.

     При отмене задачи отменяет загрузку ключей ресурса.

     - Throws: `AVAssetError.isNotPlayable`, если ресурс не поддерживает проигрывание.
     - Throws: `AVAssetError.hasProtectedContent`, если ресурс содержит защищенный контент.
     - Throws: Ошибка загрузки, если не удалось загрузить ключи ресурса.
     */
    private func loadAndValidatePlayability() async throws {
        try await withTaskCancellationHandler {
            let (isPlayable, hasProtectedContent) = try await self.load(
                .isPlayable,
                .hasProtectedContent
            )
            guard isPlayable else {
                throw AVAssetError.isNotPlayable
            }
            if hasProtectedContent {
                throw AVAssetError.hasProtectedContent
            }
        } onCancel: {
            self.cancelLoading()
        }
    }
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
     // При необходимости отмены запроса
     asset.cancelLoading()
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
