//
//  PlayerViewController.swift
//

import UIKit
import AVKit

/**
 Контроллер представления в качестве представления которого используется ``PlayerView``.
 */
open class PlayerViewController: UIViewController {
    /**
     Вариант отображения статуса загрузки.
     */
    public enum LoadingDisplayStyle {
        /**
         Статус загрузки не отображается.
         */
        case hidden
        /**
         Отображается только индикатор загрузки без текста.
         */
        case indicator
        /**
         Отображаются индикатор загрузки и подробная
         статистика ожидания.
         */
        case detailed


    }
    
    /**
     Источник данных для контроллера режима «картинка в картинке».
     
     Для управления восстановлением пользовательского интерфейса
     при выходе из режима «картинка в картинке».
     */
    public weak var pictureInPictureControllerDataSource: AVPictureInPictureControllerDataSource? {
        get { self.pipController?.dataSource }
        set { self.pipController?.dataSource = newValue }
    }
    
    /**
     Подкласс
     [UIView](https://developer.apple.com/documentation/uikit/uiview)
     поддерживаемый слоем
     [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer).
     
     Дополнительную информацию см.:
     [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
     */
    @ObservedNSObject
    public private(set) var playerView: PlayerView!
    /**
     Представление для отображения текущего состояния плеера.
     */
    public private(set) weak var statusView: PlayerStatusView!
    /**
     Представление с элементами управления плеера.
     */
    public private(set) weak var controlsView: PlayerControlsView!
    /**
     Экземпляр плеера, используемый для воспроизведения медиаконтента.
     */
    @ObservedNSObject
    public private(set) var player: AVPlayer?
    /**
     Текущий элемент воспроизведения, связанный с плеером.
     */
    @ObservedNSObject
    public private(set) var playerItem: AVPlayerItem?
    /**
     Делегат, сообщающий об ошибках воспроизведения.
     */
    public weak var playbackErrorDelegate: PlaybackErrorDelegate?

    /**
     Вариант отображения статуса загрузки.

     Значение по умолчанию — ``LoadingDisplayStyle/detailed``.
     */
    public var loadingDisplayStyle: LoadingDisplayStyle = .detailed {
        didSet {
            self.statusController?.loadingDisplayStyle =
                self.loadingDisplayStyle
        }
    }

    /**
     Контроллер отображения статуса плеера.

     Управляет ``statusView`` и определяет, какое содержимое
     отображает информационная метка.
     */
    private var statusController: PlayerStatusController?
    /**
     Наблюдатель статуса загрузки плеера.
     */
    private lazy var loadingStatusObserver = PlayerLoadingStatusObserver()
    /**
     Контроллер, управляющий выбором маршрута воспроизведения.
     */
    private var routePickerController: AVRoutePickerController?
    /**
     Контроллер режима «картинка в картинке».
     */
    private var pipController: PictureInPictureController?
    
    /**
     Создает ``PlayerView`` которым будет управлять контроллер.
     */
    open override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .black
        
        let playerView = PlayerView()
        self.playerView = playerView
        playerView.insert(into: self.view)
        
        let statusView = PlayerStatusView()
        self.statusView = statusView
        statusView.insert(into: self.view)

        let statusController = PlayerStatusController(statusView: statusView)
        statusController.loadingDisplayStyle = self.loadingDisplayStyle
        self.statusController = statusController
        
        let controlsView = PlayerControlsView()
        self.controlsView = controlsView
        controlsView.insert(into: self.view)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startPlayerStatusObserving()
        self.startExternalPlaybackObserving()
        self.startPlayerItemObserving()
        self.startPlayerItemStatusObserving()

        self.loadingStatusObserver.statusHandler = { [weak self] status in
            self?.statusController?.handleLoadingStatus(status)
        }
        
        self.$playerView.addObserver(self, keyPath: \.player) { [unowned self] playerView, _ in
            self.player = playerView.player
            if let player = playerView.player {
                self.loadingStatusObserver.register(player: player)
            } else {
                // Плеер удалён вместе с элементом воспроизведения,
                // событие окончания загрузки не придёт.
                self.loadingStatusObserver.stop()
            }
        }
        
        self.setupRetryButton()
    }
    
    /**
     Отображает информацию о состоянии плеера.

     Прерывает отображение информации о загрузке,
     если оно было начато.

     - Parameter image: Изображение статуса.
     - Parameter title: Текст статуса.
     */
    private func showStatusInfo(
        image: UIImage?,
        title: String?,
        animated: Bool = false
    ) {
        self.loadingStatusObserver.dismiss()
        self.statusController?.showMessage(
            image: image,
            title: title,
            animated: animated
        )
    }
    /**
     Скрывает информацию о состоянии плеера.
     - Parameter animated: Признак анимированного скрытия метки.
     */
    private func hideStatusInfo(animated: Bool = false) {
        self.statusController?.hideStatusInfo(animated: animated)
    }
    /**
     Начинает наблюдение за статусом плеера.
     */
    private func startPlayerStatusObserving() {
        self.$player.addObserver(self, keyPath: \.status) { [unowned self] player, _ in
            if player.status == .failed {
                let imageConfig = UIImage.SymbolConfiguration(scale: .large)
                let image = UIImage(systemName: "play.slash.fill")
                self.showStatusInfo(
                    image: image?.applyingSymbolConfiguration(imageConfig),
                    title: player.error?.localizedDescription ?? "Неизвестная ошибка.",
                    animated: true
                )
                self.playbackErrorDelegate?.playerViewController(
                    self,
                    player: player,
                    didFailWith: player.error
                )
            } else {
                self.hideStatusInfo(animated: true)
            }
            self.updateRetryButtonVisibility(playerItem: self.playerItem)
        }
    }
    
    private func startExternalPlaybackObserving() {
        self.$player.addObserver(
            self,
            keyPath: \.isExternalPlaybackActive
        ) { [unowned self] player, _ in
            self.handleExternalPlaybackStateUpdate(
                isExternalPlaybackActive: player.isExternalPlaybackActive
            )
        }
    }
    
    private func handleExternalPlaybackStateUpdate(isExternalPlaybackActive: Bool) {
        if isExternalPlaybackActive {
            let route = AVAudioSession.sharedInstance().currentRoute
            let deviceName = route.outputs.first?.portName ?? "(не определено)"
            let imageConfig = UIImage.SymbolConfiguration(scale: .large)
            let image = UIImage(systemName: "airplayvideo")
            self.showStatusInfo(
                image: image?.applyingSymbolConfiguration(imageConfig),
                title: "Идет трансляция на внешнем устройстройстве: \(deviceName)."
            )
        } else {
            self.hideStatusInfo(animated: true)
        }
    }
    
    private func startPlayerItemObserving() {
        self.$player.addObserver(
            self,
            keyPath: \.currentItem,
            options: [.initial]
        ) { [unowned self] player, _ in
            self.playerItem = player.currentItem
            // Замена элемента воспроизведения перезапускает наблюдение
            // за загрузкой: состояние старого элемента неактуально.
            self.loadingStatusObserver.register(player: player)
        }
    }
    
    private func startPlayerItemStatusObserving() {
        self.$playerItem.addObserver(
            self,
            keyPath: \.status,
            options: [.initial]
        ) { [unowned self] playerItem, _ in
            if playerItem.status == .failed {
                let imageConfig = UIImage.SymbolConfiguration(scale: .large)
                let image = UIImage(systemName: "play.slash.fill")
                self.showStatusInfo(
                    image: image?.applyingSymbolConfiguration(imageConfig),
                    title: playerItem.error?.localizedDescription ?? "Неизвестная ошибка.",
                    animated: true
                )
                self.playbackErrorDelegate?.playerViewController(
                    self,
                    playerItem: playerItem,
                    didFailWith: playerItem.error
                )
            } else {
                self.hideStatusInfo(animated: true)
            }
            self.updateRetryButtonVisibility(playerItem: playerItem)
        }
    }
    
    /**
     Включает поддержку AirPlay и отображение кнопки AirPlay.
     Настраивает обработчики событий выбора маршрута.
     */
    public func enableAirPlay() {
        self.controlsView.setupRoutePickerView()
        let routePickerController = AVRoutePickerController()
        self.routePickerController = routePickerController
        routePickerController.routePickerView = self.controlsView.routePickerView
        routePickerController.addAction(
            for: .willBeginPresentingRoutes
        ) { [weak self, unowned routePickerController] pickerView in
            if routePickerController.multipleRoutesDetected { return }
            
            let message: String
            #if targetEnvironment(simulator)
            message = """
                Функция недоступна на симуляторе. 
                Используйте реальное устройство.
                """
            #else
            message = "Нет доступных устройств."
            #endif
            let alert = UIAlertController(
                title: "Внимание!",
                message: message,
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Ок", style: .default)
            alert.addAction(action)
            self?.present(alert, animated: true)
        }
    }
    /**
     Включает режим «картинка-в-картинке».
     Добавляет кнопку PiP в элементы управления плеера.
     */
    public func enablePictureInPicture() {
        self.controlsView.setupPiPButton()
        let pipController = PictureInPictureController()
        self.pipController = pipController
        pipController.pipButton = self.controlsView.pipButton
        pipController.setupPictureInPicture(playerLayer: self.playerView.playerLayer)
    }
    /**
     Добавляет делегата для получения событий режима «картинка в картинке».
     - Parameter delegate: Объект, реализующий `AVPictureInPictureControllerEventDelegate`.
     */
    public func setPictureInPictureControllerEventDelegate(
        _ delegate: AVPictureInPictureControllerEventDelegate
    ) {
        self.pipController?.setDelegate(delegate)
    }
    /**
     Настраивает кнопку перезапуска потока и добавляет её обработчик.
     
     Кнопка размещается под надписью состояния в ``PlayerStatusView``.
     */
    private func setupRetryButton() {
        self.controlsView.setupRetryButton(below: self.statusView.infoLabel)
        self.controlsView.retryButton.addTarget(
            self,
            action: #selector(self.retryButtonPressed(_:)),
            for: .touchUpInside
        )
    }
    /**
     Обновляет видимость кнопки перезапуска потока.
     
     Кнопка отображается при ошибке плеера или элемента воспроизведения.
     Появление кнопки анимировано и задержано — сначала показывается
     текст ошибки, затем кнопка.
     
     - Parameter playerItem: Проверяемый элемент воспроизведения.
     Передаётся параметром, так как обработчик статуса может быть вызван
     до завершения присваивания `self.playerItem`.
     */
    private func updateRetryButtonVisibility(playerItem: AVPlayerItem?) {
        let isFailed = self.player?.status == .failed
            || playerItem?.status == .failed
        guard isFailed else {
            self.controlsView.retryButton.alpha = 1.0
            self.controlsView.retryButton.isHidden = true
            return
        }
        
        guard self.controlsView.retryButton.isHidden else { return }
        self.controlsView.retryButton.alpha = 0.0
        self.controlsView.retryButton.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 1.0, options: []) {
            self.controlsView.retryButton.alpha = 1.0
        }
    }
    /**
     Обрабатывает нажатие кнопки перезапуска потока.
     - Parameter sender: Кнопка, отправившая событие нажатия.
     */
    @objc private func retryButtonPressed(_ sender: UIButton) {
        sender.isHidden = true
        self.player?.retryPlayback()
    }
    
    
}

