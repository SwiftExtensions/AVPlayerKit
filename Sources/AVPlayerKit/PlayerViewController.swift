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
    public private(set) weak var playerView: PlayerView!
    /**
     Представление для отображения текущего состояния плеера.
     */
    public private(set) weak var statusView: PlayerStatusView!
    /**
     Представление с элементами управления плеера.
     */
    public private(set) weak var controlsView: PlayerControlsView!
    
    private var playerToken: NSKeyValueObservation?
    private let playerObserver = NSObjectObserver<AVPlayer>()
    private let playerItemObserver = NSObjectObserver<AVPlayerItem>()
    
    /**
     Наблюдатель зависаний плеера.
     */
    private var playerStallsObserver: PlayerStallsObserver!
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
        
        self.playerToken = self.playerView.observe(
            \.player
        ) { [unowned self] playerView, _ in
            self.playerObserver.object = playerView.player
            if let player = playerView.player {
                self.startPlayerStallsObserving(player: player)
            } else {
                self.playerStallsObserver = nil
            }
        }
    }
    
    private func startPlayerStatusObserving() {
        self.playerObserver.addObserver(
            self,
            keyPath: \.status
        ) { [unowned self] player, _ in
            if player.status == .failed {
                let message = player.error?.localizedDescription ?? "Неизвестная ошибка."
                self.statusView.showStatusInfo(message)
            } else {
                self.statusView.hideStatusInfo()
            }
        }
    }
    
    private func startExternalPlaybackObserving() {
        self.playerObserver.addObserver(
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
            let message = "Идет трансляция на внешнем устройстройстве: \(deviceName)."
            self.statusView.showStatusInfo(message)
        } else {
            self.statusView.hideStatusInfo()
        }
    }
    
    private func startPlayerItemObserving() {
        self.playerObserver.addObserver(
            self,
            keyPath: \.currentItem
        ) { [unowned self] player, _ in
            self.playerItemObserver.object = player.currentItem
        }
    }
    
    private func startPlayerItemStatusObserving() {
        self.playerItemObserver.addObserver(
            self,
            keyPath: \.status
        ) { [unowned self] playerItem, _ in
            if playerItem.status == .failed {
                let message = playerItem.error?.localizedDescription ?? "Неизвестная ошибка"
                self.statusView.showStatusInfo(message)
            } else {
                self.statusView.hideStatusInfo()
            }
        }
    }
    
    private func startPlayerStallsObserving(player: AVPlayer) {
        self.playerStallsObserver = PlayerStallsObserver()
        self.playerStallsObserver.startObserving(player: player) { [unowned self] isStalled in
            self.handlePlayerStallStateUpdate(isStalled)
        }
    }
    
    private func handlePlayerStallStateUpdate(_ isStalled: Bool) {
        if isStalled {
            self.statusView.startLoadingAnimation()
        } else {
            self.statusView.stopLoadingAnimation()
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
            message = "Нет доступных устройоств."
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
    
    deinit {
        self.playerToken?.invalidate()
    }
    
    
}

