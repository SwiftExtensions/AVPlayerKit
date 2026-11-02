//
//  AVAssetResourceLoadingRequest.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import AVFoundation

public extension AVAssetResourceLoadingRequest {
    /**
     Передаёт данные ресурса и завершает запрос.
     - Parameter data: Данные ресурса.
     - Parameter response: Ответ сервера.
     */
    func respond(
        with data: Data,
        response: URLResponse?
    ) {
        if let response {
            self.response = response
        }
        self.dataRequest?.respond(with: data)
        self.finishLoading()
    }


}
