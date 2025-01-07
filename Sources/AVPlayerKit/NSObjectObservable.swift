//
//  NSObjectObservable.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 7/1/2025.
//

import Foundation

/**
 Обертка объекта для наблюдения за его свойствами.
 
 Является синтаксическим сахаром для метода
 [observe(_:options:changeHandler:)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
 
 Пример использования:
 ```swift
 import AVFoundation
 import AVPlayerKit
 
 class SomeClass {
     @NSObjectObservable
     private var player: AVPlayer?
     
     func setupObserver() {
         self._player.addObserver(
             self,
             keyPath: \.timeControlStatus
         ) { [weak self] player, _ in
            // Обработать изменение состояния плеера.
            ...
         }
     }
 }
 ```
 */
@propertyWrapper
public class NSObjectObservable<Object> where Object : NSObject {
    /**
     Объект наблюдения.
     */
    public var wrappedValue: Object? {
        willSet {
            if self.wrappedValue != newValue {
                self.removeAllObservers()
            }
        }
    }
    /**
     Ссылки наблюдателей за объектом.
     */
    private var observers = [ObjectIdentifier : [Int : NSKeyValueObservation]]()
    /**
     Ссылки наблюдателя за объектом.
     */
    private var tokens = Set<NSKeyValueObservation>()
    
    /**
     Создать наблюдателя за объектом.
     - Parameter wrappedValue: Объект наблюдения.
     */
    public init(wrappedValue: Object?) {
        self.wrappedValue = wrappedValue
    }
    
    /**
     Добавить наблюдателя для конкретного ключа.
     
     - Note: Ключ должен поддерживать механизм наблюдения с помощью
     [KVO](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
     
     - Parameter observer: Наблюдатель.
     - Parameter keyPath: Ключевой путь для которого устанавливается наблюдение.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     
     Пример использования:
     ```swift
     import AVFoundation
     import AVPlayerKit
     
     class SomeClass {
         @NSObjectObservable
         private var player: AVPlayer?
         
         func setupObserver() {
             self._player.addObserver(
                 self,
                 keyPath: \.timeControlStatus
             ) { [weak self] player, _ in
                // Обработать изменение состояния плеера.
                ...
             }
         }
     }
     ```
     */
    public func addObserver<Observer: AnyObject, Value>(
        _ observer: Observer,
        keyPath: KeyPath<Object, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (_ object: Object, _ changes: NSKeyValueObservedChange<Value>) -> Void
    ) {
        guard let wrappedValue else { return }
        
        let token = wrappedValue.observe(keyPath, options: options, changeHandler: changeHandler)
        let id = ObjectIdentifier(observer)
        self.observers[id, default: [:]].updateValue(token, forKey: keyPath.hashValue)
    }
    /**
     Удалить наблюдателя.
     - Parameter observer: Наблюдатель.
     */
    public func removeObserver<Observer: AnyObject>(
        _ observer: Observer
    ) {
        let id = ObjectIdentifier(observer)
        self.observers[id]?.values.forEach { $0.invalidate() }
        self.observers[id] = nil
    }
    /**
     Удалить наблюдателя для конкретного ключа.
     - Parameter observer: Наблюдатель.
     - Parameter keyPath: Ключевой путь от корневого типа к типу результирующего значения.
     */
    public func removeObserver<Observer: AnyObject, Value>(
        _ observer: Observer,
        keyPath: KeyPath<NSObjectObservable, Value>
    ) {
        let id = ObjectIdentifier(observer)
        self.observers[id]?[keyPath.hashValue]?.invalidate()
        self.observers[id]?[keyPath.hashValue] = nil
    }
    /**
     Установить наблюдателя для конкретного ключа.
     
     - Note: Ключ должен поддерживать механизм наблюдения с помощью
     [KVO](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
     
     - Parameter keyPath: Ключевой путь для которого устанавливается наблюдение.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     
     Пример использования:
     ```swift
     import AVFoundation
     import AVPlayerKit
     
     class SomeClass {
         @NSObjectObservable
         private var player: AVPlayer?
         // NSObjectObservable хранит сильную ссылку,
         // токен нужен только для возможности удаления наблюдения.
         private weak var token: NSKeyValueObservation?
         
         func setupObserver() {
             self.token = self._player.startObserving(\.timeControlStatus) { [weak self] player, _ in
                // Обработать изменение состояния плеера.
                ...
             }
         }
     }
     ```
     */
    @discardableResult
    public func startObserving<Value>(
        _ keyPath: KeyPath<Object, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Object, NSKeyValueObservedChange<Value>) -> Void
    ) -> NSKeyValueObservation? {
        guard let wrappedValue else { return nil }
        
        let token = wrappedValue.observe(keyPath, options: options, changeHandler: changeHandler)
        self.tokens.update(with: token)
        
        return token
    }
    /**
     Удалить наблюдателя для конкретного ключа.
     - Parameter token: Токен наблюдателя, который необходимо удалить.
     */
    public func stopObserving(_ token: NSKeyValueObservation?) {
        guard let token else { return }
        self.tokens.remove(token)?.invalidate()
    }
    /**
     Удалить всех наблюдателей.
     */
    public func removeAllObservers() {
        self.observers.values.forEach {
            $0.values.forEach { $0.invalidate() }
        }
        self.observers = [:]
        self.tokens.forEach { $0.invalidate() }
        self.tokens.removeAll()
    }
    
    deinit {
        self.removeAllObservers()
    }
    
    
}
