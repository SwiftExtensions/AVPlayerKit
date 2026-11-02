//
//  AVAssetLoaderInterceptor.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import AVFoundation

/**
 Делегат перехвата загрузки ресурсов HLS потока через `AVAssetResourceLoader`.

 Перехватываются запросы с нестандартной схемой
 с префиксом `intercepted-` (_например, `intercepted-https`_):
 исходная схема восстанавливается срезанием префикса.

 Запросы плейлистов `.m3u8` перехватчик загружает самостоятельно
 и передаёт делегату данные для преобразования.
 Остальные запросы передаются делегату целиком.

 Делегаты опциональны: при отсутствии делегата
 запрос передаётся плееру без обработки
 (_плейлист — данными без преобразования, медиаресурс — редиректом_).

 - Note: `AVAssetResourceLoader` перехватывает загрузку только
 для схем, отличных от `http`/`https`.

 ## Пример
 ```swift
 import AVFoundation

 final class PlaybackController: NSObject {
     let player = AVPlayer()
     let interceptor = AVAssetLoaderInterceptor()

     func play(url: URL) throws {
         // Создать элемент проигрывателя с перехватом загрузки ресурсов
         let playerItem = try self.interceptor.playerItem(from: url)
         self.interceptor.playlistDelegate = self
         self.interceptor.mediaDelegate = self

         self.player.replaceCurrentItem(with: playerItem)
         self.player.play()
     }
 }

 extension PlaybackController: AVAssetLoaderInterceptorPlaylistDelegate {
     func assetLoaderInterceptor(
         _ interceptor: AVAssetLoaderInterceptor,
         m3u8Data: Data,
         originalRequest: URLRequest,
         completion: @escaping (Data) -> Void
     ) {
         // Преобразование плейлиста
         completion(m3u8Data)
     }
 }
 
 extension PlaybackController: AVAssetLoaderInterceptorMediaDelegate {
     func assetLoaderInterceptor(
         _ interceptor: AVAssetLoaderInterceptor,
         resourceFor originalURL: URL,
         loadingRequest: AVAssetResourceLoadingRequest
     ) {
         // Обработка перехваченного запроса
         interceptor.redirect(to: originalURL, loadingRequest: loadingRequest)
     }
 }
 ```
 */
public final class AVAssetLoaderInterceptor: NSObject {
    /**
     Делегат обработки перехваченных запросов загрузки плейлистов.
     */
    public weak var playlistDelegate: AVAssetLoaderInterceptorPlaylistDelegate?
    /**
     Делегат обработки перехваченных запросов загрузки медиаресурсов.
     */
    public weak var mediaDelegate: AVAssetLoaderInterceptorMediaDelegate?

    /**
     Очередь отправки вызовов методов делегирования.
     */
    let queue: DispatchQueue

    /**
     Создаёт перехватчик загрузки ресурсов HLS потока.
     - Parameter queue: Очередь отправки вызовов методов делегирования.
     */
    public init(queue: DispatchQueue = DispatchQueue(label: "AVAssetLoaderInterceptor")) {
        self.queue = queue
    }

    /**
     Перенаправляет запрос ресурса на исходный URL.

     Плеер самостоятельно обработает редирект и загрузит ресурс.
     - Parameter originalURL: Исходный URL ресурса.
     - Parameter loadingRequest: Запрос загрузки ресурса.
     */
    public func redirect(to originalURL: URL, loadingRequest: AVAssetResourceLoadingRequest) {
        var redirectRequest = loadingRequest.request
        redirectRequest.url = originalURL
        loadingRequest.redirect = redirectRequest
        loadingRequest.response = HTTPURLResponse(
            url: originalURL,
            statusCode: 302,
            httpVersion: nil,
            headerFields: nil
        )
        loadingRequest.finishLoading()
    }


}

// MARK: - Создание

public extension AVAssetLoaderInterceptor {
    /**
     Создаёт актив с перехватом загрузки ресурсов.

     Схема исходного URL переписывается на перехватываемую,
     перехватчик назначается загрузчику ресурсов актива.

     - Parameter originalURL: Исходный URL потока.
     - Parameter options: Параметры инициализации актива.
     - Returns: Актив с перехватываемым URL.
     - Throws: `URLError.badURL`, если не удалось переписать схему URL.
     */
    func asset(
        from originalURL: URL,
        options: [String: Any]? = nil
    ) throws -> AVURLAsset {
        let interceptedURL = try InterceptedURL(original: originalURL).intercepted()
        let asset = AVURLAsset(url: interceptedURL, options: options)
        self.register(asset: asset)

        return asset
    }
    /**
     Создаёт элемент проигрывателя с перехватом загрузки ресурсов.

     Схема исходного URL переписывается на перехватываемую,
     перехватчик назначается загрузчику ресурсов актива.

     - Parameter originalURL: Исходный URL потока.
     - Parameter options: Параметры инициализации актива.
     - Returns: Элемент проигрывателя.
     - Throws: `URLError.badURL`, если не удалось переписать схему URL.
     */
    func playerItem(
        from originalURL: URL,
        options: [String: Any]? = nil
    ) throws -> AVPlayerItem {
        let asset = try self.asset(from: originalURL, options: options)
        return AVPlayerItem(asset: asset)
    }


}

// MARK: - Регистрация

public extension AVAssetLoaderInterceptor {
    /**
     Назначает перехватчика загрузки ресурсов актива.
     - Parameter asset: Актив, загрузка ресурсов которого перехватывается.
     */
    func register(asset: AVURLAsset) {
        asset.resourceLoader.setDelegate(self, queue: self.queue)
    }
    /**
     Назначает перехватчика загрузки ресурсов элемента проигрывателя.
     - Parameter playerItem: Элемент проигрывателя,
     загрузка ресурсов актива которого перехватывается.
     */
    func register(playerItem: AVPlayerItem) {
        guard let asset = playerItem.asset as? AVURLAsset else {
            return
        }
        self.register(asset: asset)
    }


}

// MARK: - AVAssetResourceLoaderDelegate

extension AVAssetLoaderInterceptor: AVAssetResourceLoaderDelegate {
    public func resourceLoader(
        _ resourceLoader: AVAssetResourceLoader,
        shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
    ) -> Bool {
        guard let url = loadingRequest.request.url else {
            let error = URLError.missingRequestURL
            loadingRequest.finishLoading(with: error)
            return true
        }

        do {
            let originalURL = try InterceptedURL(intercepted: url).original

            if originalURL.pathExtension == "m3u8" {
                var originalRequest = loadingRequest.request
                originalRequest.url = originalURL
                self.loadM3U8(originalRequest, loadingRequest: loadingRequest)
            } else {
                guard let mediaDelegate else {
                    // Делегат не назначен — ресурс передаётся плееру без обработки
                    self.redirect(to: originalURL, loadingRequest: loadingRequest)
                    return true
                }
                mediaDelegate.assetLoaderInterceptor(
                    self,
                    resourceFor: originalURL,
                    loadingRequest: loadingRequest
                )
            }
        } catch {
            loadingRequest.finishLoading(with: error)
        }

        return true
    }
    /**
     Загружает плейлист по исходному запросу
     и передаёт делегату данные для преобразования.
     - Parameter originalRequest: Исходный запрос загрузки плейлиста.
     - Parameter loadingRequest: Запрос загрузки ресурса.
     */
    private func loadM3U8(
        _ originalRequest: URLRequest,
        loadingRequest: AVAssetResourceLoadingRequest
    ) {
        URLSession.shared.dataTask(with: originalRequest) { [weak self] data, response, error in
            if loadingRequest.isCancelled { return }
            guard let data else {
                let error = error ?? URLError.failedToLoad(originalRequest)
                loadingRequest.finishLoading(with: error)
                return
            }
            guard let self else { return }
            guard let playlistDelegate else {
                // Делегат не назначен — плейлист передаётся плееру без преобразования
                self.queue.async {
                    if loadingRequest.isCancelled { return }
                    loadingRequest.respond(with: data, response: response)
                }
                return
            }
            
            playlistDelegate.assetLoaderInterceptor(
                self,
                m3u8Data: data,
                originalRequest: originalRequest
            ) { transformedData in
                self.queue.async {
                    if loadingRequest.isCancelled { return }
                    loadingRequest.respond(with: transformedData, response: response)
                }
            }
        }.resume()
    }


}
