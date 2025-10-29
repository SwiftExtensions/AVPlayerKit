//
//  NSObjectRepresentable.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 29/10/2025.
//

import Foundation

/**
 Протокол, который позволяет исползовать как опциональный, так и непоциональный тип NSObject.
 */
public protocol NSObjectRepresentable {
    /**
     Корневой тип объекта.
     */
    associatedtype RawValue: NSObject
    /**
     Корневой объект.
     */
    var rawValue: RawValue? { get }
    
    
}

/**
 Расширение, позволяющее использовать `NSObject` как `NSObjectRepresentable`.
 */
extension NSObject: NSObjectRepresentable {
    /**
     Тип-синоним для `NSObject`.
     */
    public typealias RawValue = NSObject
    /**
     Возвращает исходный `NSObject`.
     */
    public var rawValue: Self? { self }
    
    
}

/**
 Расширение, добавляющее поддержку `NSObjectRepresentable` для опциональных `NSObject`.
 */
extension Optional: NSObjectRepresentable where Wrapped: NSObject {
    /**
     Тип-синоним для исходного опционального `NSObject`.
     */
    public typealias RawValue = Wrapped
    /**
     Возвращает исходный опциональный `NSObject`.
     */
    public var rawValue: Wrapped? { self }
    
    
}
