//
//  AnyOptional.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 13.11.2025.
//

protocol AnyOptional {
    /**
     Возвращает `true` если `nil`, в противном случае `false`.
     */
    var isNil: Bool { get }
    
    
}

extension Optional: AnyOptional {
    /**
     Возвращает `true` если `nil`, в противном случае `false`.
     */
    var isNil: Bool { self == nil }
    
    
}
