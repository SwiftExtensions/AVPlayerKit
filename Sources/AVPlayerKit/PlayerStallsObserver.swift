//
//  PlayerStallsObserver.swift
//

import AVFoundation

/**
 Наблюдатель зависаний плеера.
 
 Доступно управление задержкой уведомления о зависании плеера с помощью параметра
 `delayTimeInterval`, значение по умолчанию 1.0 с.
 При этом зависания менее 1 с не будут учитываться.
 */
final class PlayerStallsObserver {
    typealias ChangeHandler = (_ isStalled: Bool) -> Void
    
    private(set) var player: AVPlayer?
    private var playerWaitingToPlayToken: NSKeyValueObservation?
    private(set) var isStalled: Bool?
    private var changeHandler: ChangeHandler?
    
    private weak var delayTimer: Timer?
    /**
     Задержка для уведомления о зависании плеера, с.
     
     Для имитации отсутствия зависаний плеера.
     Значение по умолчанию 1.0 с.
     */
    var delayTimeInterval: TimeInterval = 1.0
    
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
        self.resetDelayTimer()
        
        if isStalled && self.delayTimeInterval > 0.0 {
            self.setupDelayTimer()
        } else {
            self.changeHandler?(isStalled)
        }
    }
    
    private func setupDelayTimer() {
        let delayTimer = Timer(timeInterval: self.delayTimeInterval, repeats: false) { [weak self] _ in
            self?.changeHandler?(true)
        }
        self.delayTimer = delayTimer
        RunLoop.main.add(delayTimer, forMode: .common)
    }
    
    private func resetDelayTimer() {
        self.delayTimer?.invalidate()
        self.delayTimer = nil
    }
    
    deinit {
        self.resetDelayTimer()
        self.playerWaitingToPlayToken?.invalidate()
    }
    
    
}
