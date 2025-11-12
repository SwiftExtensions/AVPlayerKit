//
//  OptionalType.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 12.11.2025.
//


/**
 Интерфейс для типов, инкапсулирующих опциональное значение.
 Позволяет абстрагироваться от конкретной реализации `Optional`
 и получать опционал через единый интерфейс.
 
 ## Пример использования:
 
 ```swift
 func processValue<T>(_ value: T) -> String {
     if let optionalValue = value as? OptionalType {
         // Работаем с опциональным значением через протокол
         if let unwrapped = optionalValue.optional {
             return "Значение: \(unwrapped)"
         } else {
             return "Значение отсутствует"
         }
     } else {
         // Работаем с обычным значением
         return "Значение: \(value)"
     }
 }
 
 let a: Int? = 42
 let b: String? = nil
 let c: Double = 3.14
 
 print(processValue(a)) // "Значение: 42"
 print(processValue(b)) // "Значение отсутствует"
 print(processValue(c)) // "Значение: 3.14"
 ```
 */
protocol OptionalType {
    /**
     Тип оборачиваемого значения.
     Используется для описания базового (неопционального) типа,
     который может присутствовать или отсутствовать.
     */
    associatedtype Wrapped
    
    /**
     Исходное опциональное значение.
     
     - Returns: Значение типа `Wrapped`, если оно присутствует, иначе `nil`.
     */
    var optional: Wrapped? { get }
    
    
}

extension Optional: OptionalType {
    /**
     Возвращает исходное опциональное значение.
     
     - Returns: Значение типа `Wrapped`, если оно присутствует, иначе `nil`.
     */
    var optional: Self { self }
    
    
}
