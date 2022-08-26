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
        let errorDescription: String?
        switch self {
        case .isNotPlayable:
            errorDescription = "Контент не поддерживает проигрывание."
        case .hasProtectedContent:
            errorDescription = "Контент защищен от проигрывания."
        }
        
        return errorDescription
    }
    
    
}
