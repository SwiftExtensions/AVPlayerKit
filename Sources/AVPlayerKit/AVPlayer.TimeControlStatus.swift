//
//  AVPlayer.TimeControlStatus.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 17/10/2025.
//

import AVFoundation

public extension AVPlayer.TimeControlStatus {
    /**
     Текстовое представление статуса воспроизведения плеера.
     */
    var customDescription: String {
        let description: String
        switch self {
        case .paused:
            description = "paused"
        case .waitingToPlayAtSpecifiedRate:
            description = "waitingToPlayAtSpecifiedRate"
        case .playing:
            description = "playing"
        @unknown default:
            description = "unknown"
        }
        
        return description
    }
    
    
}
