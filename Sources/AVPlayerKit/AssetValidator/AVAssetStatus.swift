//
//  AVAssetStatus.swift
//  AVPlayerContainerKit
//
//  Created by Александр Алгашев on 30.10.2026.
//

import Foundation

/**
 Состояние проверяемого ресурса.
 */
public enum AVAssetStatus {
    /**
     Состояние неизвестно — ресурс ещё не проверялся.
     */
    case unknown
    /**
     Ресурс готов к воспроизведению.
     */
    case readyToPlay
    /**
     Воспроизведение невозможно из-за ошибки.

     - Parameter error: Возникшая ошибка.
     */
    case failed(Error)
    /**
     Ресурс проверяется или обрабатывается.
     */
    case processing


}


