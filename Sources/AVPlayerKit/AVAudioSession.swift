//
//  AVAudioSession.swift
//

import AVFoundation

public extension AVAudioSession {
    func configureVideoPlayback() throws {
        if #available(iOS 11.0, *) {
            try self.setCategory(.playback, mode: .spokenAudio, policy: .longForm, options: [])
        } else if #available(iOS 10.0, *) {
            try self.setCategory(.playback, mode: .spokenAudio, options: [])
        } else {
            try self.setCategory(.playback)
        }
        try self.setActive(true)
    }
    
    static func configureVideoPlayback() throws {
        try AVAudioSession.sharedInstance().configureVideoPlayback()
    }
    
    
}
