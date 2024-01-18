//
//  PlayerStallsObserver.swift
//

import AVFoundation

/**
 Наблюдатель зависаний плеера.
 */
final class PlayerStallsObserver {
    typealias ChangeHandler = (_ isStalled: Bool) -> Void
    
    private var player: AVPlayer?
    private var playerWaitingToPlayToken: NSKeyValueObservation?
    private var isStalled: Bool?
    private var changeHandler: ChangeHandler?
    
    func startObserving(player: AVPlayer, changeHandler: @escaping (_ isStalled: Bool) -> Void) {
        self.player = player
        self.changeHandler = changeHandler
        if player.currentItem != nil {
            let isStalled = player.reasonForWaitingToPlay != nil
            self.notifyIsStalled(isStalled)
        }
        self.playerWaitingToPlayToken = player.observe(\.reasonForWaitingToPlay) { [weak self] player, _ in
            let isStalled = player.reasonForWaitingToPlay != nil
            self?.notifyIsStalled(isStalled)
        }
    }
    
    private func notifyIsStalled(_ isStalled: Bool) {
        guard self.isStalled != isStalled else { return }
        self.isStalled = isStalled
        self.changeHandler?(isStalled)
    }
    
    deinit {
        self.playerWaitingToPlayToken?.invalidate()
    }
    
    
}
