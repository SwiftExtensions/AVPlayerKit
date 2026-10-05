//
//  AVPlayer.Status.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 05.10.2026.
//

import AVFoundation

public extension AVPlayer.Status {
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
