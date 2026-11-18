//
//  PlayerLoadingStatusObserver.swift
//
//

import AVFoundation

/**
 Наблюдатель статуса загрузки плеера.

 Отслеживает зависание плеера с помощью ``PlayerStallsObserver``
 и сообщает о жизненном цикле загрузки через ``statusHandler``:

 - `started` — плеер ожидает данные дольше ``stallDelay``;
 - `updated` — метрики загрузки: причина ожидания и длительность
   ожидания, объём загруженных данных и скорость сети из журнала
   доступа, длительность буферизованных данных;
 - `finished` — загрузка завершилась;
 - `interrupted` — отслеживание прервано другим статусом.

 Метрики предназначены для отображения пользователю во время
 длительного ожидания загрузки, чтобы отличить продолжающуюся
 загрузку от зависания приложения.

 ### Пример
 ```swift
 let observer = PlayerLoadingStatusObserver()
 observer.metricsDelay = 3.0
 observer.statusHandler = { status in
     switch status {
     case .stalled:
         // Показать индикатор загрузки
     case .loading(let info):
         // Отобразить метрики загрузки
     case .finished:
         // Скрыть индикатор загрузки
     case .interrupted:
         // Отслеживание прервано другим статусом
     }
 }
 observer.register(player: player)
 ```
 */
public class PlayerLoadingStatusObserver {
    /**
     Статус загрузки плеера.
     */
    public enum Status {
        /**
         Зависание: плеер ожидает данные дольше ``stallDelay``.
         */
        case stalled
        /**
         Метрики загрузки обновились.

         - Parameter info: Текст метрик.
         */
        case loading(info: String)
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
     Задержка в секундах перед сообщением о начале загрузки.

     Позволяет сгладить краткосрочные паузы воспроизведения:
     зависания короче задержки не учитываются.
     Значение по умолчанию — `1.0`.
     */
    public var stallDelay: TimeInterval {
        get { self.stallsObserver?.delayTimeInterval ?? 1.0 }
        set { self.stallsObserver?.delayTimeInterval = newValue }
    }
    /**
     Задержка в секундах перед первой передачей метрик.

     Метрики отображаются только при длительном ожидании данных.
     Значение по умолчанию — `5.0`.
     */
    public var metricsDelay: TimeInterval = 5.0
    /**
     Обработчик изменений статуса загрузки.
     */
    public var statusHandler: ((Status) -> Void)?

    /**
     Наблюдатель зависаний плеера.

     Создается при регистрации плеера и освобождается
     при окончании отслеживания.
     */
    private var stallsObserver: PlayerStallsObserver?
    /**
     Зарегистрированный экземпляр плеера.

     Хранится слабой ссылкой.
     */
    private weak var player: AVPlayer?
    /**
     Таймер периодического сбора метрик загрузки.
     */
    private weak var metricsTimer: Timer?
    /**
     Дата начала текущего ожидания загрузки.
     */
    private var startDate: Date?
    /**
     Признак того, что загрузка идёт.

     Все изменения выполняются самим наблюдателем.
     */
    private var isInProgress = false
    /**
     Признак того, что статус загрузки уступил другому статусу.

     Влияет на итоговое событие: вместо `finished`
     будет доставлено `interrupted`.
     */
    private var isDismissed = false

    /**
     Создает экземпляр наблюдателя статуса загрузки плеера.
     */
    public init() { }

    deinit {
        self.metricsTimer?.invalidate()
    }

    /**
     Регистрирует плеер для отслеживания загрузки.

     Наблюдение за прежним плеером прекращается.
     Если плеер уже ожидает данных, загрузка будет сообщена
     с задержкой ``stallDelay``.

     - Parameter player: Плеер, для которого отслеживается загрузка.
     */
    public func register(player: AVPlayer) {
        self.metricsTimer?.invalidate()
        self.metricsTimer = nil
        self.startDate = nil
        self.isInProgress = false
        self.isDismissed = false
        self.player = player

        let stallsObserver = PlayerStallsObserver()
        self.stallsObserver = stallsObserver
        stallsObserver.startObserving(player: player) { [weak self] isStalled in
            self?.handleStallChange(isStalled)
        }
    }
    /**
     Заканчивает отслеживание загрузки.

     Останавливает наблюдение и сообщает о завершении загрузки.
     Если статус загрузки уступил другому статусу,
     сообщает о прерывании.
     */
    public func stop() {
        self.stallsObserver = nil
        self.metricsTimer?.invalidate()
        self.metricsTimer = nil
        self.startDate = nil
        defer { self.isInProgress = false }
        guard self.isInProgress else {
            self.statusHandler?(.interrupted)
            return
        }
        self.statusHandler?(.finished)
    }
    /**
     Прерывает отображение статуса загрузки.

     Применяется, когда статус загрузки уступает другому статусу
     (например, ошибке). Сбор метрик останавливается, а по окончании
     ожидания вместо `finished` будет доставлено `interrupted`.
     */
    public func dismiss() {
        self.metricsTimer?.invalidate()
        self.metricsTimer = nil
        self.startDate = nil
        self.isDismissed = true
    }

    /**
     Обрабатывает изменение состояния зависания плеера.
     - Parameter isStalled: Признак того, что плеер ожидает данные.
     */
    private func handleStallChange(_ isStalled: Bool) {
        if isStalled {
            if self.isInProgress { return }
            self.beginStall()
        } else {
            guard self.isInProgress else { return }
            self.finish()
        }
    }
    /**
     Фиксирует зависание: запускает сбор метрик
     и сообщает статус.
     */
    private func beginStall() {
        self.isInProgress = true
        self.startDate = Date()
        self.setupMetricsTimer()
        self.statusHandler?(.stalled)
    }
    /**
     Завершает отсчёт загрузки и сообщает итоговое событие.
     */
    private func finish() {
        self.isInProgress = false
        self.metricsTimer?.invalidate()
        self.metricsTimer = nil
        self.startDate = nil
        defer { self.isDismissed = false }
        if self.isDismissed {
            self.statusHandler?(.interrupted)
        } else {
            self.statusHandler?(.finished)
        }
    }
    /**
     Настраивает таймер периодического сбора метрик загрузки.
     */
    private func setupMetricsTimer() {
        let timer = Timer(
            timeInterval: 1.0,
            repeats: true
        ) { [weak self] _ in
            self?.update()
        }
        self.metricsTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    /**
     Собирает актуальные метрики загрузки и сообщает статус.
     */
    private func update() {
        guard self.player != nil else {
            self.metricsTimer?.invalidate()
            self.metricsTimer = nil
            return
        }

        let elapsed = self.startDate.map {
            Date().timeIntervalSince($0)
        } ?? 0
        guard elapsed >= self.metricsDelay else { return }

        let reason = self.player?.reasonForWaitingToPlay
        let reasonText = reason?.displayDescription ?? "Загрузка"
        var lines = ["\(reasonText)… \(Int(elapsed)) с"]

        let metrics = self.metricsDescription()
        if !metrics.isEmpty {
            lines.append(metrics)
        }

        self.statusHandler?(.loading(info: lines.joined(separator: "\n")))
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
