//
//  PlayerLoadingStatusObserver.swift
//
//

import AVFoundation

/**
 Наблюдатель статуса загрузки плеера.

 Отслеживает жизненный цикл загрузки и собирает метрики,
 сообщая о событиях через ``statusHandler``:

 - причина ожидания плеера и длительность ожидания;
 - объём загруженных данных и скорость сети из журнала доступа;
 - длительность буферизованных данных.

 Строка метрик предназначена для отображения пользователю во время
 длительного ожидания загрузки, чтобы отличить продолжающуюся
 загрузку от зависания приложения.

 ### Пример
 ```swift
 let observer = PlayerLoadingStatusObserver()
 observer.delay = 3.0
 observer.statusHandler = { event in
     switch event {
     case .started:
         // Показать индикатор загрузки
     case .updated(let info):
         // Отобразить info или очистить текст при nil
     case .finished:
         // Скрыть индикатор загрузки
     case .interrupted:
         // Отслеживание прервано другим статусом
     }
 }
 observer.start(player: player)
 ```
 */
public class PlayerLoadingStatusObserver {
    /**
     Событие жизненного цикла загрузки.
     */
    public enum Status {
        /**
         Загрузка началась: плеер ожидает данные.
         */
        case started
        /**
         Метрики загрузки обновились.

         - Parameter info: Текст метрик или `nil`,
           если метрики ещё не должны отображаться.
         */
        case updated(info: String?)
        /**
         Загрузка завершилась.
         */
        case finished
        /**
         Отслеживание загрузки прервано другим статусом.
         */
        case interrupted
    }

    /**
     Задержка в секундах перед первой передачей метрик.

     Метрики отображаются только при длительном ожидании данных.
     Значение по умолчанию — `5.0`.
     */
    public var delay: TimeInterval = 5.0
    /**
     Обработчик событий жизненного цикла загрузки.
     */
    public var statusHandler: ((Status) -> Void)?

    /**
     Признак того, что загрузка идёт.

     Все изменения выполняются самим наблюдателем.
     */
    private var isInProgress = false
    /**
     Зарегистрированный экземпляр плеера.

     Хранится слабой ссылкой. Элемент воспроизведения берётся
     из currentItem плеера, отдельная передача не требуется.
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
     Создает экземпляр наблюдателя статуса загрузки плеера.
     */
    public init() { }

    deinit {
        self.timer?.invalidate()
    }

    /**
     Начинает отслеживание загрузки.

     - Parameter player: Плеер, для которого собираются метрики.
       Может быть `nil`.
     */
    public func start(player: AVPlayer?) {
        self.isInProgress = true
        self.statusHandler?(.started)
        guard let player else { return }
        self.register(player: player)
    }
    /**
     Заканчивает отслеживание загрузки.

     Останавливает сбор метрик и сообщает о завершении загрузки.
     Если отслеживание было прервано другим статусом,
     сообщает о прерывании.
     */
    public func stop() {
        self.stopUpdates()
        defer { self.isInProgress = false }
        guard self.isInProgress else {
            self.statusHandler?(.interrupted)
            return
        }
        self.statusHandler?(.finished)
    }
    /**
     Прерывает отслеживание загрузки.

     Применяется, когда статус загрузки уступает другому статусу
     (например, ошибке). Сбор метрик останавливается.
     */
    public func dismiss() {
        self.stopUpdates()
        self.isInProgress = false
    }
    /**
     Обновляет плеер, для которого собираются метрики загрузки.

     - Parameter player: Плеер, для которого собираются метрики.
     */
    public func register(player: AVPlayer) {
        self.stopUpdates()
        self.player = player
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
    private func stopUpdates() {
        self.timer?.invalidate()
        self.timer = nil
        self.startDate = nil
    }
    /**
     Собирает актуальные метрики загрузки и сообщает событие.
     */
    private func update() {
        guard self.player != nil else {
            self.stopUpdates()
            self.statusHandler?(.updated(info: nil))
            return
        }

        let elapsed = self.startDate.map {
            Date().timeIntervalSince($0)
        } ?? 0
        guard elapsed >= self.delay else {
            self.statusHandler?(.updated(info: nil))
            return
        }

        let reason = self.player?.reasonForWaitingToPlay
        let reasonText = reason?.displayDescription ?? "Загрузка"
        var lines = ["\(reasonText)… \(Int(elapsed)) с"]

        let metrics = self.metricsDescription()
        if !metrics.isEmpty {
            lines.append(metrics)
        }

        self.statusHandler?(.updated(info: lines.joined(separator: "\n")))
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
