//
//  AVAssetLoaderInterceptorMediaDelegate.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 02.11.2026.
//

import AVFoundation

/**
 Источник ресурса перехваченного запроса загрузки медиаресурса.
 */
public protocol AVAssetLoaderInterceptorMediaDelegate: AnyObject {
    /**
     Даёт ресурс для перехваченного запроса загрузки.

     Обязан завершить запрос ровно один раз:
     - данными: `loadingRequest.dataRequest?.respond(with:)` + `finishLoading()`;
     - редиректом: `interceptor.redirect(to:loadingRequest:)`;
     - ошибкой: `loadingRequest.finishLoading(with:)`.

     - Parameter interceptor: Перехватчик загрузки ресурсов,
     предоставляющий обработку запроса средствами плеера.
     - Parameter originalURL: Исходный URL ресурса.
     - Parameter loadingRequest: Запрос загрузки ресурса.
     */
    func assetLoaderInterceptor(
        _ interceptor: AVAssetLoaderInterceptor,
        resourceFor originalURL: URL,
        loadingRequest: AVAssetResourceLoadingRequest
    )


}
