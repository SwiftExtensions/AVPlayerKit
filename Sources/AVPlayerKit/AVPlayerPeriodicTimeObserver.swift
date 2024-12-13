//
//  AVPlayerPeriodicTimeObserver.swift
//

import AVFoundation

/**
 Наблюдатель за изменением времени плеера во время воспроизведения.
 
 Наблюдатель держит сильную ссылку на объект.
 
 Является синтаксическим сахаром для метода
 [addPeriodicTimeObserver(forInterval:queue:using:)](https://developer.apple.com/documentation/avfoundation/avplayer/1385829-addperiodictimeobserver).
 
 Пример использования:
 ```swift
 import AVFoundation
 
 let timeObserver = AVPlayerPeriodicTimeObserver(player: PLAYER)
 timeObserver.startObserving(forInterval: TIME_INTERVAL) { [weak self] time in
     // Обработать изменение времени плеера.
     ...
 }
 ```
 */
public class AVPlayerPeriodicTimeObserver {
    /**
     Плеер воспроизведения.
     */
    public let player: AVPlayer
    /**
     Ссылки наблюдателя за плеером.
     */
    private var tokens = [ObjectIdentifier : Any]()
    
    /**
     Создать наблюдателя за плеером.
     - Parameter player: Плеер воспроизведения.
     */
    public init(player: AVPlayer) {
        self.player = player
    }
    
    /**
     Начать наблюдение за временем плеера воспроизведения.
     - Parameter interval: Интервал времени.
     - Parameter queue: Очередь отправки событий. Если не указана,
     используется главная очередь. Корректная работа гарантирована только на последовательной очереди.
     - Parameter block: Блок обработки.
     
     Пример использования:
     ```swift
     import AVFoundation
     
     let timeObserver = AVPlayerPeriodicTimeObserver(player: PLAYER)
     timeObserver.startObserving(forInterval: TIME_INTERVAL) { [weak self] time in
         // Обработать изменение времени плеера.
         ...
     }
     ```
     */
    @discardableResult
    public func startObserving(
        forInterval interval: CMTime,
        queue: dispatch_queue_t? = nil,
        using block: @escaping @Sendable (_ time: CMTime) -> Void
    ) -> Any {
        let timeObserverToken = self.player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: queue,
            using: block
        )
        
        let token = ObjectIdentifier(timeObserverToken as AnyObject)
        self.tokens[token] = timeObserverToken
        
        return timeObserverToken
    }
    /**
     Начать наблюдение за временем плеера воспроизведения.
     - Parameter interval: Интервал времени, с.
     - Parameter queue: Очередь отправки событий. Если не указана,
     используется главная очередь. Корректная работа гарантирована только на последовательной очереди.
     - Parameter block: Блок обработки.
     
     Пример использования:
     ```swift
     import AVFoundation
     
     let timeObserver = AVPlayerPeriodicTimeObserver(player: PLAYER)
     timeObserver.startObserving(forInterval: TIME_INTERVAL) { [weak self] time in
         // Обработать изменение времени плеера.
         ...
     }
     ```
     */
    @discardableResult
    public func startObserving(
        forInterval interval: TimeInterval,
        queue: dispatch_queue_t? = nil,
        using block: @escaping @Sendable (_ time: CMTime) -> Void
    ) -> Any {
        let interval = CMTime(
            seconds: interval,
            preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        )
        
        return self.startObserving(
            forInterval: interval,
            queue: queue,
            using: block
        )
    }
    
    
}
