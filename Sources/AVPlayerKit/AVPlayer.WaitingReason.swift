//
//  AVPlayer.WaitingReason.swift
//  

import AVFoundation

extension AVPlayer.WaitingReason {
    /**
     Пользовательское описание причины ожидания воспроизведения.
     
     Предназначено для внутреннего использования при формировании
     метрик загрузки в ``AVPlayerItemLoadingMetrics``.
     Для внешнего применения используйте значение самой причины
     `reasonForWaitingToPlay` — например, `.toMinimizeStalls`.
     */
    var displayDescription: String {
        let description: String
        switch self {
        case .toMinimizeStalls:
            description = "Буферизация"
        case .evaluatingBufferingRate:
            description = "Оценка скорости сети"
        case .noItemToPlay:
            description = "Нет элемента воспроизведения"
        default:
            description = "Загрузка"
        }
        
        return description
    }
    
    
}
