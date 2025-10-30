//
//  NSObjectObserver.swift
//

import Foundation

/**
 Наблюдатель за свойствами объекта.
 
 Наблюдатель держит сильную ссылку на объект.
 
 Является синтаксическим сахаром для метода
 [observe(_:options:changeHandler:)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
 
 ## Подходы к наблюдению
 
 ### 1. Прямое наблюдение через `startObserving`
 **Используйте когда:**
 - Нужно наблюдать за одним свойством с возможностью замены обработчика
 - Наблюдение за свойством должно быть уникальным (один `keyPath` = один обработчик)
 - Автоматическое восстановление наблюдений при замене объекта
 
 **Примеры:** Отслеживание состояния плеера, наблюдение за прогрессом.
 
 ### 2. Групповое наблюдение через `addObserver`
 **Используйте когда:**
 - Компонент создает несколько наблюдений за разными свойствами
   *(например, менеджер следит за player.state, player.currentTime, player.duration)*
 - Все наблюдения должны быть удалены одновременно
   *(например, в `deinit` компонента)*
 - Не хочется управлять отдельными наблюдениями вручную
 
 **Примеры:** Менеджер с множественными подписками, сервис с группой наблюдений.
 
 ### Пример
 ```swift
 import AVFoundation
 
 let playerObserver = NSObjectObserver(object: PLAYER)
 
 // Прямое наблюдение
 playerObserver.startObserving(\.timeControlStatus) { player, _ in
    // Обработать изменение состояния плеера.
 }
 
 // Групповое наблюдение
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
     Объект наблюдения.
     */
    public var object: Object? {
        willSet {
            self.invalidateTokens()
            guard let object = newValue else { return }
            
            // Восстановить прямые наблюдения
            self.observations.forEach { key, value in
                self.tokens[key] = value(object)
            }
            // Восстановить групповые наблюдения
            self.groupedObservations.forEach { ownerID, observations in
                observations.forEach { keyPathID, observation in
                    let token = observation(object)
                    self.groupedObservers[ownerID, default: [:]][keyPathID] = token
                }
            }
        }
    }
    /**
     Ссылки наблюдателя за объектом для прямых подписок.
     */
    private var tokens = [ObjectIdentifier : NSKeyValueObservation]()
    /**
     Наблюдатели для прямых подписок.
     */
    private var observations = [ObjectIdentifier : (Object) -> NSKeyValueObservation]()
    /**
     Карта токенов, сгруппированных по владельцам и ключевым путям для группового наблюдения.
     */
    private var groupedObservers: [ObjectIdentifier: [ObjectIdentifier : NSKeyValueObservation]] = [:]
    /**
     Наблюдатели для группового наблюдения, сохраненные для восстановления при смене объекта.
     */
    private var groupedObservations: [ObjectIdentifier: [ObjectIdentifier : (Object) -> NSKeyValueObservation]] = [:]
    
    /**
     Создать наблюдателя за объектом.
     */
    public init() { }
    /**
     Создать наблюдателя за объектом.
     - Parameter object: Объект наблюдения.
     */
    public init(object: Object?) {
        self.object = object
    }
    
    /**
     Установить наблюдателя для конкретного свойства (_ключевого пути_) объекта.
     
     - Note: Свойство (_ключевой путь_) должно поддерживать механизм наблюдения с помощью
     [KVO](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
     
     - Important: В случае смены наблюдаемого объекта,
     все ранее примененные наблюдатели будут назначены новому объекту.
     
     - Parameter keyPath: Ключевой путь (_свойство_) для которого устанавливается наблюдение.
     - Parameter options: Значения, которые могут быть возвращены в словаре изменений.
     - Parameter changeHandler: Блок, вызываемый при изменении значения.
     - Returns: Токен наблюдения.
     
     Пример использования:
     ```swift
     import AVFoundation
     
     let playerObserver = NSObjectObserver(object: PLAYER)
     playerObserver.startObserving(\.timeControlStatus) { [weak self] player, _ in
        // Обработать изменение состояния плеера.
        ...
     }
     */
    public func startObserving<Value>(
        _ keyPath: KeyPath<Object, Value>,
        options: NSKeyValueObservingOptions = [],
        changeHandler: @escaping (Object, NSKeyValueObservedChange<Value>) -> Void
    ) {
        self.stopObserving(keyPath)
        let token = self.object.rawValue?.observe(
            keyPath,
            options: options,
            changeHandler: changeHandler
        )
        let keyPathID = ObjectIdentifier(keyPath)
        self.tokens[keyPathID] = token
        let observation: (Object) -> NSKeyValueObservation = { object in
            object.observe(keyPath, options: options, changeHandler: changeHandler)
        }
        self.observations[keyPathID] = observation
    }
    /**
     Удалить наблюдателя для конкретного свойства (_ключевого пути_) объекта.
     - Parameter keyPath: Ключевой путь от корневого типа к типу результирующего значения.
     
     Пример использования:
     ```swift
     import AVFoundation
     
     let playerObserver = NSObjectObserver(object: PLAYER)
     playerObserver.startObserving(\.timeControlStatus) { [weak self] player, _ in
        // Обработать изменение состояния плеера.
        ...
     }
     ...
     playerObserver.stopObserving(\.timeControlStatus)
     */
    public func stopObserving<Value>(_ keyPath: KeyPath<Object, Value>) {
        let keyPathID = ObjectIdentifier(keyPath)
        if let token = self.tokens.removeValue(forKey: keyPathID) {
            token.invalidate()
        }
        self.observations.removeValue(forKey: keyPathID)
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
        guard let object = self.object.rawValue else { return }
        
        let token = object.observe(
            keyPath,
            options: options,
            changeHandler: changeHandler
        )
        let ownerID = ObjectIdentifier(observer)
        let keyPathID = ObjectIdentifier(keyPath)
        self.groupedObservers[ownerID, default: [:]].updateValue(token, forKey: keyPathID)?.invalidate()
        
        let observation: (Object) -> NSKeyValueObservation = { object in
            object.observe(keyPath, options: options, changeHandler: changeHandler)
        }
        self.groupedObservations[ownerID, default: [:]].updateValue(observation, forKey: keyPathID)
    }
    /**
     Удалить все наблюдения для конкретного владельца.
     - Parameter observer: Объект, для которого удаляются все наблюдения.
     */
    public func removeObserver(_ observer: AnyObject) {
        let ownerID = ObjectIdentifier(observer)
        self.groupedObservers.removeValue(forKey: ownerID)?.forEach { $1.invalidate() }
        self.groupedObservations.removeValue(forKey: ownerID)
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
        let ownerID = ObjectIdentifier(observer)
        let keyPathID = ObjectIdentifier(keyPath)
        self.groupedObservers[ownerID]?.removeValue(forKey: keyPathID)?.invalidate()
        self.groupedObservations[ownerID]?.removeValue(forKey: keyPathID)
        
        if self.groupedObservers[ownerID]?.isEmpty == true {
            self.groupedObservers.removeValue(forKey: ownerID)
        }
        if self.groupedObservations[ownerID]?.isEmpty == true {
            self.groupedObservations.removeValue(forKey: ownerID)
        }
    }
    /**
     Удалить наблюдателя для всех ключей.
     */
    public func invalidate() {
        self.invalidateTokens()
        self.observations.removeAll()
        self.groupedObservers.forEach { $1.forEach { $1.invalidate() } }
        self.groupedObservers.removeAll()
        self.groupedObservations.removeAll()
    }
    /**
     Удалить токены для прямых наблюдений.
     */
    private func invalidateTokens() {
        self.tokens.values.forEach { $0.invalidate() }
        self.tokens.removeAll()
        self.groupedObservers.forEach { $1.forEach { $1.invalidate() } }
        self.groupedObservers.removeAll()
    }
    
    deinit {
        self.invalidate()
    }
    
    
}
