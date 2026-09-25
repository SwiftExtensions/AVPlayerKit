//
//  PlayerPlaybackStartLocker.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 25.09.2026.
//

import AVFoundation

/**
 Блокировщик запуска воспроизведения `AVPlayer`.

 Пока блокировка активна, любая попытка начать воспроизведение
 (`rate` стал больше нуля) немедленно откатывается вызовом `pause()`.
 */
public final class PlayerPlaybackStartLocker {
    /**
     Плеер, у которого блокируется запуск воспроизведения.
     */
    private weak var player: AVPlayer?
    /**
     Наблюдатель за `rate` плеера. `nil`, если блокировка не активна.
     */
    private var rateObserver: NSKeyValueObservation?
    
    /**
     Создаёт блокировку запуска воспроизведения для указанного плеера.
     - Parameter player: Плеер, у которого блокируется запуск воспроизведения.
     */
    public init(player: AVPlayer) {
        self.player = player
    }
    
    /**
     Включает блокировку запуска воспроизведения.

     Повторный вызов обновляет наблюдение. Если плеер уже освобождён,
     блокировка не включается.
     */
    public func lock() {
        guard let player else { return }
        
        self.rateObserver?.invalidate()
        self.rateObserver = player.observe(\.rate) { player, _ in
            // Откат происходит в два этапа:
            // 1. pause() отменяет команду play — rate возвращается в 0.0.
            // 2. Буферизация могла успеть стартовать, поэтому AVPlayer сам
            //    вернёт rate в 1.0, даже если ранее был вызов pause и
            //    timeControlStatus == .paused. Наблюдатель сработает на каждый
            //    такой отскок и повторит pause.
            guard player.rate > 0.0 else { return }
            let isPaused = player.timeControlStatus == .paused
            player.pause()
            #if DEBUG
            // Отсекаем внутреннее дребезжание rate: плеер уже был на паузе,
            // значит реальной попытки запуска не было — логировать нечего.
            if isPaused { return }
            let message = "❌ Попытка запуска воспроизведения отменена: активна блокировка."
            print("\(Self.self).\(#function)+\(#line) \(message)")
            #endif
        }
    }
    /**
     Снимает блокировку запуска воспроизведения.
     */
    public func unlock() {
        self.rateObserver?.invalidate()
        self.rateObserver = nil
    }
    
    
}
