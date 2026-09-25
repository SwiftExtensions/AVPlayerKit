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
            if player.rate > 0 { player.pause() }
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
