//
//  AVAssetLoaderInterceptorPlaylistDelegate.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import Foundation

/**
 Источник ресурса перехваченного запроса загрузки плейлиста.
 */
public protocol AVAssetLoaderInterceptorPlaylistDelegate: AnyObject {
    /**
     Даёт ресурс для перехваченного запроса загрузки плейлиста.

     Плейлист уже загружен перехватчиком по исходному запросу.
     Делегат преобразует данные и передаёт результат в блок завершения.

     - Parameter interceptor: Перехватчик загрузки ресурсов.
     - Parameter m3u8Data: Данные загруженного плейлиста.
     - Parameter originalRequest: Исходный запрос загрузки плейлиста
     (_копия запроса плеера с восстановленным исходным URL_).
     - Parameter completion: Блок завершения, в который делегат передаёт
     данные ресурса для плеера.
     */
    func assetLoaderInterceptor(
        _ interceptor: AVAssetLoaderInterceptor,
        m3u8Data: Data,
        originalRequest: URLRequest,
        completion: @escaping (_ data: Data) -> Void
    )


}
