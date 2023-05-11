//
//  AVAssetError.swift
//

import AVFoundation

/**
 Ошибка медиа источника.
 */
public enum AVAssetError: Error {
    /**
     Контент не поддерживает проигрывание.
     */
    case isNotPlayable
    /**
     Контент защищен от проигрывания.
     */
    case hasProtectedContent
    
    
}

// MARK: LocalizedError

extension AVAssetError: LocalizedError {
    /**
     Текстовое представление ошибки медиа источника.
     */
    public var errorDescription: String? {
        let description: String?
        switch self {
        case .isNotPlayable:
            description = "Контент не поддерживает проигрывание."
        case .hasProtectedContent:
            description = "Контент защищен от проигрывания."
        }
        
        return description
    }
    
    
}
