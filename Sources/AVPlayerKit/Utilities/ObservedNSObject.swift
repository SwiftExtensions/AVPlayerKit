//
//  ObservedNSObject.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 12.11.2025.
//



import Foundation

/**
 Обертка объекта для наблюдения за его свойствами.
 
 Является синтаксическим сахаром для метода
 [observe(_:options:changeHandler:)](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift).
 
 Пример использования:
 ```swift
 import AVFoundation
 import SwiftFoundation
 
 class SomeClass {
    @ObservedNSObject
    private var player: AVPlayer?
     
    func setupObserver() {
        self.player = AVPlayer(url: URL)
        // Наблюдателей можно устанавливать, как до, так и после установки
        // наблюдаемого объекта.
        self.$player.startObserving(\.timeControlStatus) { [weak self] player, _ in
            // Обработать изменение состояния плеера.
            ...
        }
    }
 }
 ```
 */
@propertyWrapper
public class ObservedNSObject<Object> {
    /**
     Объект наблюдения.
     */
    public var wrappedValue: Object {
        get { self.projectedValue.object }
        set { self.projectedValue.object = newValue }
    }
    /**
     Наблюдатель за свойствами объекта.
     */
    public let projectedValue: NSObjectObserver<Object>
    
    /**
     Создать наблюдателя за объектом.
     */
    public init<Wrapped>() where Object == Wrapped?, Wrapped: NSObject {
        self.projectedValue = NSObjectObserver()
    }
    /**
     Создать наблюдателя за объектом.
     - Parameter wrappedValue: Объект наблюдения.
     */
    public init(wrappedValue: Object) where Object: NSObject {
        self.projectedValue = NSObjectObserver(object: wrappedValue)
    }
    /**
     Создать наблюдателя за объектом.
     - Parameter wrappedValue: Объект наблюдения.
     */
    public init<Wrapped>(wrappedValue: Object) where Object == Wrapped?, Wrapped: NSObject {
        self.projectedValue = NSObjectObserver(object: wrappedValue)
    }
    
    
}
