//
//  AVPlayerItem.Status.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 03.10.2025.
//

import AVFoundation

public extension AVPlayerItem.Status {
    /**
     Текстовое представление статуса элемента воспроизведения плеера.
     */
    var customDescription: String {
        let description: String
        switch self {
        case .unknown:
            description = "unknown"
        case .readyToPlay:
            description = "readyToPlay"
        case .failed:
            description = "failed"
        @unknown default:
            description = "unknown"
        }
        
        return description
    }
    
    
}
