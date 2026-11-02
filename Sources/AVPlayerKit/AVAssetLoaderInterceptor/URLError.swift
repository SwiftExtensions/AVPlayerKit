//
//  URLError.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import Foundation

extension URLError {
    /**
     У запроса отсутствует URL.
     */
    static var missingRequestURL: URLError {
        URLError(.badURL, localizedDescription: "У запроса отсутствует URL.")
    }
    /**
     Не удалось загрузить ресурс по указанному запросу.

     - Parameter request: Запрос загрузки.
     */
    static func failedToLoad(_ request: URLRequest) -> URLError {
        let urlString = request.url?.absoluteString ?? "empty url"
        let localizedDescription = "Не удалось загрузить: \(urlString)."
        return URLError(.badServerResponse, localizedDescription: localizedDescription)
    }
    
    /**
     Создаёт ошибку URL с локализованным описанием.

     - Parameter code: Код ошибки.
     - Parameter localizedDescription: Описание ошибки.
     */
    init(
        _ code: URLError.Code,
        localizedDescription: String
    ) {
        self.init(code, userInfo: [NSLocalizedDescriptionKey: localizedDescription])
    }


}
