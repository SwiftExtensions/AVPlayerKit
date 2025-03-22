//
//  NSObjectObserver.swift
//

import Foundation

/**
 Наблюдатель за свойствами объекта.
 
 Наблюдатель держит сильную ссылку на объект.
 
 Является синтаксическим сахаром для метода
 [observe(_:options:changeHandler:)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
 
 Пример использования:
 ```swift
 import AVFoundation
 
 let playerObserver = NSObjectObserver(object: PLAYER)
 playerObserver.startObserving(\.timeControlStatus) { player, _ in
    // Обработать изменение состояния плеера.
    ...
 }
 ```
 */
public class NSObjectObserver<Object: NSObject> {
    /**
     Объект наблюдения.
     */
    public let object: Object
    /**
     Ссылки наблюдателя за объектом.
     */
    private var tokens = [Int : NSKeyValueObservation]()
    
    /**
     Создать наблюдателя за объектом.
     - Parameter object: Объект наблюдения.
     */
    public init(object: Object) {
        self.object = object
    }
    
    /**
     Установить наблюдателя для конкретного свойства (_ключевого пути_) объекта.
     
     - Note: Свойство (_ключевой путь_) должно поддерживать механизм наблюдения с помощью
     [KVO](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
     
     - Parameter keyPath: Ключевой путь (_свойство_) для которого устанавливается наблюдение.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     - Returns: Токен наблюдения.
     
     Пример использования:
     ```swift
     import AVFoundation
     
     let playerObserver = NSObjectObserver(object: PLAYER)
     playerObserver.startObserving(\.timeControlStatus) { player, _ in
        // Обработать изменение состояния плеера.
        ...
     }
     */
    @discardableResult
    public func startObserving<Value>(
        _ keyPath: KeyPath<Object, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Object, NSKeyValueObservedChange<Value>) -> Void
    ) -> NSKeyValueObservation {
        self.stopObserving(keyPath)
        let token = self.object.observe(keyPath, options: options, changeHandler: changeHandler)
        self.tokens[keyPath.hashValue] = token
        
        return token
    }
    /**
     Удалить наблюдателя для конкретного свойства (_ключевого пути_) объекта.
     - Parameter keyPath: Ключевой путь от корневого типа к типу результирующего значения.
     */
    public func stopObserving<Value>(_ keyPath: KeyPath<Object, Value>) {
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
