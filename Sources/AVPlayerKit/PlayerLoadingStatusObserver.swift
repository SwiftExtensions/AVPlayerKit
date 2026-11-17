//
//  PlayerLoadingStatusObserver.swift
//

import AVFoundation

/**
 Наблюдатель статуса загрузки плеера.
 
 Класс периодически, раз в секунду, собирает актуальные данные
 о процессе загрузки и передаёт их обработчику в виде готовой строки:
 
 - причина ожидания плеера и длительность ожидания;
 - объём загруженных данных и скорость сети из журнала доступа;
 - длительность буферизованных данных.
 
 Строка предназначена для отображения пользователю во время
 длительного ожидания загрузки, чтобы отличить продолжающуюся
 загрузку от зависания приложения.
 
 ### Пример
 ```swift
 let observer = PlayerLoadingStatusObserver()
 observer.delay = 3.0
 observer.register(player: player) { info in
     // Отобразить info или скрыть индикатор при nil
 }
 ```
 */
public class PlayerLoadingStatusObserver {
    /**
     Тип обработчика, уведомляющего об обновлении метрик загрузки.
     
     - Parameter info: Строка с метриками загрузки или `nil`,
       если метрики ещё не должны отображаться.
     */
    public typealias UpdateHandler = (_ info: String?) -> Void
    
    /**
     Задержка в секундах перед первой передачей метрик обработчику.
     
     Метрики отображаются только при длительном ожидании данных.
     Значение по умолчанию — `5.0`.
     */
    public var delay: TimeInterval = 5.0
    
    /**
     Зарегистрированный экземпляр плеера.
     
     Хранится слабой ссылкой. Элемент воспроизведения берётся из
     [currentItem](https://developer.apple.com/documentation/avfoundation/avplayer/1387569-currentitem)
     плеера, отдельная передача не требуется.
     */
    private weak var player: AVPlayer?
    
    /**
     Дата начала текущего ожидания загрузки.
     */
    private var startDate: Date?
    /**
     Таймер периодического сбора метрик загрузки.
     */
    private weak var timer: Timer?
    /**
     Обработчик, уведомляющий внешний код об обновлении метрик.
     */
    private var updateHandler: UpdateHandler?
    
    /**
     Создает экземпляр сборщика метрик загрузки.
     */
    public init() { }
    
    deinit {
        self.timer?.invalidate()
    }
    
    /**
     Регистрирует плеер и запускает периодический сбор метрик загрузки.
     
     - Parameters:
       - player: Экземпляр плеера, для которого собираются метрики.
       - updateHandler: Обработчик, получающий строку метрик
         или `nil`, если метрики ещё не должны отображаться.
     */
    public func register(
        player: AVPlayer,
        updateHandler: @escaping UpdateHandler
    ) {
        self.stopUpdates()
        self.player = player
        self.updateHandler = updateHandler
        self.startDate = Date()
        self.update()
        
        let timer = Timer(
            timeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.update()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    /**
     Останавливает сбор метрик загрузки.
     */
    public func stopUpdates() {
        self.timer?.invalidate()
        self.timer = nil
        self.startDate = nil
        self.updateHandler = nil
    }
    /**
     Собирает актуальные метрики загрузки и уведомляет обработчик.
     */
    private func update() {
        guard self.player != nil else {
            self.stopUpdates()
            self.updateHandler?(nil)
            return
        }
        
        let elapsed = self.startDate.map {
            Date().timeIntervalSince($0)
        } ?? 0
        guard elapsed >= self.delay else {
            self.updateHandler?(nil)
            return
        }
        
        let reason = self.player?.reasonForWaitingToPlay
        let reasonText = reason?.displayDescription ?? "Загрузка"
        var lines = ["\(reasonText)… \(Int(elapsed)) с"]
        
        let metrics = self.metricsDescription()
        if !metrics.isEmpty {
            lines.append(metrics)
        }
        
        self.updateHandler?(lines.joined(separator: "\n"))
    }
    /**
     Собирает строку сетевых метрик и состояния буфера.
     
     - Returns: Строка вида «получено 14,2 МБ • 3,1 Мбит/с • буфер 6 с»
       или пустая строка, если метрики недоступны.
     */
    private func metricsDescription() -> String {
        guard let playerItem = self.player?.currentItem else { return "" }
        
        var metrics: [String] = []
        if let bytes = playerItem.totalBytesTransferred() {
            let text = ByteCountFormatter.string(
                fromByteCount: bytes,
                countStyle: .file
            )
            metrics.append("получено \(text)")
        }
        if let bitrate = playerItem.accessLog()?.events.last?.observedBitrate,
           bitrate > 0.0 {
            metrics.append(
                String(format: "%.1f Мбит/с", bitrate / 1_000_000)
            )
        }
        if let buffered = playerItem.bufferedAhead(), buffered >= 1.0 {
            metrics.append("буфер \(Int(buffered.rounded())) с")
        }
        
        return metrics.joined(separator: " • ")
    }
    
    
}
