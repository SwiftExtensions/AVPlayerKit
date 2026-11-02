//
//  InterceptedURL.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import Foundation

/**
 URL, загрузка которого перехватывается.

 Переписывает схему исходного URL на перехватываемую:
 `https://example.com/master.m3u8` → `intercepted-https://example.com/master.m3u8`.
 */
public struct InterceptedURL {
    /**
     Префикс перехватываемой схемы.
     */
    public static let interceptedSchemePrefix = "intercepted-"
    /**
     Исходный URL.
     */
    public let original: URL

    /**
     Создаёт URL из исходного.
     - Parameter original: Исходный URL.
     */
    public init(original: URL) {
        self.original = original
    }
    /**
     Создаёт URL из перехватываемого, восстанавливая исходный.
     - Parameter intercepted: Перехватываемый URL.
     - Throws: `URLError.badURL`, если схема URL не перехватываемая
     или не удалось создать URL из компонентов.
     */
    public init(intercepted: URL) throws {
        guard
            let interceptedScheme = intercepted.scheme
        else {
            let description = "У URL отсутствует схема: \(intercepted)."
            throw URLError(.badURL, localizedDescription: description)
        }
        let (scheme, isDropped) = interceptedScheme.dropPrefix(Self.interceptedSchemePrefix)
        guard isDropped else {
            let description = "Схема URL не перехватываемая: \(intercepted)."
            throw URLError(.badURL, localizedDescription: description)
        }

        var components = URLComponents(url: intercepted, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        guard let original = components?.url else {
            let description = "Не удалось создать URL из компонентов: \(intercepted)."
            throw URLError(.badURL, localizedDescription: description)
        }

        self.original = original
    }

    /**
     Переписывает схему исходного URL на перехватываемую.
     - Returns: URL с перехватываемой схемой.
     - Throws: `URLError.badURL`, если у URL отсутствует схема
     или не удалось создать URL из компонентов.
     */
    public func intercepted() throws -> URL {
        var components = URLComponents(url: self.original, resolvingAgainstBaseURL: false)
        guard let originalScheme = components?.scheme else {
            let description = "У URL отсутствует схема: \(self.original)."
            throw URLError(.badURL, localizedDescription: description)
        }

        components?.scheme = Self.interceptedSchemePrefix + originalScheme
        guard let url = components?.url else {
            let description = "Не удалось создать URL из компонентов: \(self.original)."
            throw URLError(.badURL, localizedDescription: description)
        }

        return url
    }


}
