//
//  AVPlayerObserver.swift
//

import AVFoundation

/**
 Наблюдатель за плеером.
 
 Наблюдатель держит сильную ссылку на плеер.
 */
@available(*, deprecated,
    renamed: "NSObjectObserver",
    message: "Используйте более общий класс NSObjectObserver.")
public class AVPlayerObserver {
    /**
     Плеер воспроизведения.
     */
    public let player: AVPlayer
    /**
     Ссылки наблюдателя за плеером.
     */
    private var tokens = [Int : NSKeyValueObservation]()
    
    /**
     Создать наблюдателя за плеером.
     - Parameter player: Плеер воспроизведения.
     */
    public init(player: AVPlayer) {
        self.player = player
    }
    
    /**
     Установить наблюдателя.
     - Parameter keyPath: Ключевой путь от корневого типа к типу результирующего значения.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     */
    public func observe<Value>(
        _ keyPath: KeyPath<AVPlayer, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (AVPlayer, NSKeyValueObservedChange<Value>) -> Void)
    {
        self.removeObserver(keyPath)
        let token = self.player.observe(keyPath, options: options, changeHandler: changeHandler)
        self.tokens[keyPath.hashValue] = token
    }
    /**
     Удалить наблюдателя для конкретного ключа.
     - Parameter keyPath: Ключевой путь от корневого типа к типу результирующего значения.
     */
    public func removeObserver<Value>(_ keyPath: KeyPath<AVPlayer, Value>) {
        if let token = self.tokens.removeValue(forKey: keyPath.hashValue) {
            token.invalidate()
        }
    }
    /**
     Удалить наблюдателя для всех ключей.
     */
    public func invalidate() {
        self.tokens.values.forEach { $0.invalidate() }
        self.tokens = [:]
    }
    
    deinit {
        self.invalidate()
    }
    
    
    
}
