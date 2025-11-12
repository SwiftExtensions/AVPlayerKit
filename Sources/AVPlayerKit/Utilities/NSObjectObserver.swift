//
//  NSObjectObserver.swift
//

import Foundation

/**
 Наблюдатель за свойствами объекта.
 
 Наблюдатель держит сильную ссылку на объект.
 
 Является синтаксическим сахаром для метода
 [observe(_:options:changeHandler:)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
 
 ### Пример
 ```swift
 import AVFoundation
 
 let playerObserver = NSObjectObserver(object: PLAYER)
 
 playerObserver.addObserver(self, keyPath: \.currentTime) { player, _ in
    // Обработать изменение времени
 }
 playerObserver.addObserver(self, keyPath: \.duration) { player, _ in
    // Обработать изменение длительности
 }
 // Удалить все наблюдения владельца
 playerObserver.removeObserver(self)
 ```
 */
public class NSObjectObserver<Object> where Object : NSObject {
    /**
     Строитель наблюдения для конкретного объека.
     */
    typealias ObservationBuilder = (Object) -> NSKeyValueObservation
    
    /**
     Объект наблюдения.
     */
    public var object: Object? {
        willSet {
            self.invalidateTokens()
            guard let object = newValue else { return }
            
            // Восстановить групповые наблюдения
            self.observations.forEach { observerID, observations in
                observations.forEach { keyPathID, observation in
                    let token = observation(object)
                    self.observers[observerID, default: [:]][keyPathID] = token
                }
            }
        }
    }
    /**
     Карта токенов, сгруппированных по владельцам и ключевым путям для группового наблюдения.
     */
    private var observers: [ObjectIdentifier: [ObjectIdentifier : NSKeyValueObservation]] = [:]
    /**
     Наблюдатели для группового наблюдения, сохраненные для восстановления при смене объекта.
     */
    private var observations: [ObjectIdentifier: [ObjectIdentifier : ObservationBuilder]] = [:]
    
    /**
     Создать наблюдателя за объектом.
     */
    public init() {}
    /**
     Создать наблюдателя за объектом.
     - Parameter object: Объект наблюдения.
     */
    public init(object: Object?) {
        self.object = object
    }
    /**
     Добавить наблюдателя, привязанного к внешнему объекту.
     
     - Note: Позволяет группировать несколько наблюдений под одним владельцем.
     Все наблюдения владельца можно удалить одним вызовом `removeObserver(_:)`.
     
     - Parameter observer: Объект-владелец наблюдения, используется как идентификатор для группировки.
     - Parameter keyPath: Ключевой путь для которого устанавливается наблюдение.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     
     ### Пример
     ```swift
     final class PlayerManager {
         private let playerObserver: NSObjectObserver<AVPlayer>
         
         init(player: AVPlayer) {
             self.playerObserver = NSObjectObserver(object: player)
         }
         
         func startObserving() {
             self.playerObserver.addObserver(self, keyPath: \.timeControlStatus) { [weak self] player, _ in
                 self?.handleStatusChange()
             }
             self.playerObserver.addObserver(self, keyPath: \.currentTime) { [weak self] player, _ in
                 self?.handleTimeUpdate()
             }
         }
         
         deinit {
             self.playerObserver.removeObserver(self)
         }
     }
     ```
     */
    public func addObserver<Value>(
        _ observer: AnyObject,
        keyPath: KeyPath<Object, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Object, NSKeyValueObservedChange<Value>) -> Void
    ) {
        let observerID = ObjectIdentifier(observer)
        self.stopObserving(keyPath, observer: observerID)
        
        let keyPathID = ObjectIdentifier(keyPath)
        self.observers[observerID, default: [:]][keyPathID] = self.object?.observe(
            keyPath,
            options: options,
            changeHandler: changeHandler
        )
        
        let observation: (Object) -> NSKeyValueObservation = { object in
            object.observe(keyPath, options: options, changeHandler: changeHandler)
        }
        self.observations[observerID, default: [:]].updateValue(observation, forKey: keyPathID)
    }
    /**
     Прекратить наблюдение владельца по конкретному ключевому пути.
     - Parameter keyPath: Ключевой путь KVO, который требуется снять.
     - Parameter observer: Объект, для которого удаляется наблюдение.
     */
    private func stopObserving<Value>(
        _ keyPath: KeyPath<Object, Value>,
        observer observerID: ObjectIdentifier
    ) {
        let keyPathID = ObjectIdentifier(keyPath)
        self.observers[observerID]?.removeValue(forKey: keyPathID)?.invalidate()
        self.observations[observerID]?.removeValue(forKey: keyPathID)
    }
    /**
     Удалить все наблюдения для конкретного владельца.
     - Parameter observer: Объект, для которого удаляются все наблюдения.
     */
    public func removeObserver(_ observer: AnyObject) {
        let observerID = ObjectIdentifier(observer)
        self.observers.removeValue(forKey: observerID)?.forEach { $1.invalidate() }
        self.observations.removeValue(forKey: observerID)
    }
    /**
     Удалить наблюдение владельца по конкретному ключевому пути.
     - Parameter observer: Объект, для которого удаляется наблюдение.
     - Parameter keyPath: Ключевой путь, который требуется снять.
     */
    public func removeObserver<Value>(
        _ observer: AnyObject,
        keyPath: KeyPath<Object, Value>
    ) {
        let observerID = ObjectIdentifier(observer)
        self.stopObserving(keyPath, observer: observerID)
        
        guard self.observers[observerID]?.isEmpty == true else { return }
        
        self.observers.removeValue(forKey: observerID)
        self.observations.removeValue(forKey: observerID)
    }
    /**
     Удалить наблюдателя для всех ключей.
     */
    public func invalidate() {
        self.invalidateTokens()
        self.observations.removeAll()
    }
    /**
     Удалить токены для прямых наблюдений.
     */
    private func invalidateTokens() {
        self.observers.forEach { $1.forEach { $1.invalidate() } }
        self.observers.removeAll()
    }
    
    deinit {
        self.invalidate()
    }
    
    
}
