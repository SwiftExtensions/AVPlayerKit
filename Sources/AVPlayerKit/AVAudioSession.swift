//
//  AVAudioSession.swift
//

import AVFoundation

public extension AVAudioSession {
    /**
     Установить режим проигрывания фильмов для аудиосессии.
     */
    func configureMoviePlayback() throws {
        try self.setCategory(.playback, mode: .moviePlayback, policy: .longForm, options: [])
        try self.setActive(true)
    }
    /**
     Установить режим проигрывания фильмов для аудиосессии.
     */
    static func configureMoviePlayback() throws {
        try AVAudioSession.sharedInstance().configureMoviePlayback()
    }
    
    
}
