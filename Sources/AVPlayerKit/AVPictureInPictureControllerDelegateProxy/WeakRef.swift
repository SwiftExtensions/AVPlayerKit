//
//  WeakRef.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 20.10.2025.
//

/**
 Контейнер со слабой ссылкой на объект.
 */
struct WeakRef<Object: AnyObject> {
    /**
     Объект (_слабая ссылка_).
     */
    weak var object: Object?
    
    /**
     Создает контейнер со слабой ссылкой на объект.
     - Parameter object: Объект, ссылка на который должна быть сохранена.
     */
    init(_ object: Object?) {
        self.object = object
    }
    
    
}
