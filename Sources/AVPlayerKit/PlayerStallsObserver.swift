//
//  PlayerStallsObserver.swift
//

import AVFoundation

/**
 Наблюдатель зависаний плеера.
 
 Доступно управление задержкой уведомления о зависании плеера с помощью параметра
 `delayTimeInterval`, значение по умолчанию 1.0 с.
 При этом зависания менее 1 с не будут учитываться.
 
 ### Пример
 ```swift
 let observer = PlayerStallsObserver()
 observer.delayTimeInterval = 1.5

 observer.startObserving(player: player) { isStalled in
     if isStalled {
         // Отобразить индикатор буферизации
     } else {
         // Скрыть индикатор и продолжить воспроизведение
     }
 }
 ```
 */
public class PlayerStallsObserver {
    /**
     Тип обратного вызова, уведомляющего об актуальном состоянии зависания плеера.
     
     - Parameter isStalled: Состояние зависания плеера. Значение `true` означает,
       что воспроизведение заблокировано ожиданием новых данных.
     */
    public typealias ChangeHandler = (_ isStalled: Bool) -> Void
    
    /**
     Текущий отслеживаемый экземпляр плеера.
     
     Значение становится `nil`, если наблюдение остановлено или ещё не начато.
     */
    private(set) var player: AVPlayer?
    /**
     Токен KVO-наблюдения свойства ``AVPlayer/reasonForWaitingToPlay``.
     
     Используется для своевременной остановки наблюдения при деинициализации.
     */
    private var playerWaitingToPlayToken: NSKeyValueObservation?
    /**
     Последнее зафиксированное состояние зависания плеера.
     
     `nil` до первого определения состояния.
     */
    private(set) var isStalled: Bool?
    /**
     Обработчик, уведомляющий внешний код о смене состояния зависания.
     */
    private var changeHandler: ChangeHandler?
    /**
     Таймер, обеспечивающий отложенное оповещение о зависании.
     */
    private weak var delayTimer: Timer?
    /**
     Интервал задержки перед уведомлением о зависании, в секундах.
     
     Позволяет сгладить краткосрочные паузы воспроизведения. Если в течение
     `delayTimeInterval` воспроизведение возобновится, обратный вызов не будет
     вызван с `true`.
     
     Значение по умолчанию — `1.0`.
     */
    public var delayTimeInterval: TimeInterval = 1.0
    
    /**
     Создает новый экземпляр наблюдателя зависаний плеера.
     */
    public init() { }
    
    /**
     Начинает отслеживание состояния указанного экземпляра плеера.
     
     Метод запоминает переданный плеер и немедленно вызывает обработчик с
     актуальным состоянием, если плеер уже ожидает данных.
     
     - Parameter player: Экземпляр плеера, за которым необходимо наблюдать.
     - Parameter changeHandler: Обработчик, получающий уведомление о смене
       состояния зависания.
     */
    public func startObserving(
        player: AVPlayer,
        changeHandler: @escaping ChangeHandler
    ) {
        self.player = player
        self.changeHandler = changeHandler
        if player.currentItem != nil {
            let isStalled = player.reasonForWaitingToPlay != nil
            self.notifyIsStalled(isStalled)
        }
        self.playerWaitingToPlayToken = player.observe(
            \.reasonForWaitingToPlay
        ) { [weak self] player, _ in
            let isStalled = player.reasonForWaitingToPlay != nil
            self?.notifyIsStalled(isStalled)
        }
    }
    
    /**
     Обновляет внутреннее состояние зависания и уведомляет обработчик с учётом задержки.
     
     - Parameter isStalled: Новое состояние зависания плеера.
     */
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
    /**
     Настраивает таймер задержки перед отправкой уведомления о зависании.
     */
    private func setupDelayTimer() {
        let delayTimer = Timer(
            timeInterval: self.delayTimeInterval,
            repeats: false
        ) { [weak self] _ in
            self?.changeHandler?(true)
        }
        self.delayTimer = delayTimer
        RunLoop.main.add(delayTimer, forMode: .common)
    }
    /**
     Останавливает и сбрасывает таймер задержки уведомления.
     */
    private func resetDelayTimer() {
        self.delayTimer?.invalidate()
        self.delayTimer = nil
    }
    /**
     Освобождает ресурсы, отменяя наблюдение и активные таймеры перед уничтожением объекта.
     */
    deinit {
        self.resetDelayTimer()
        self.playerWaitingToPlayToken?.invalidate()
    }
    
    
}
