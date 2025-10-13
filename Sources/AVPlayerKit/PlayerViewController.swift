//
//  PlayerViewController.swift
//

import UIKit
import AVFoundation

/**
 Контроллер представления в качестве представления которого используется ``PlayerView``.
 */
@available(iOS 13.0, *)
open class PlayerViewController: UIViewController {
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
    private var playerObserver: NSObjectObserver<AVPlayer>?
    private var playerItemObserver: NSObjectObserver<AVPlayerItem>?
    
    private var routePickerController: AVRoutePickerController?
    /**
     Наблюдатель зависаний плеера.
     */
    private var playerStallsObserver: PlayerStallsObserver!
    
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
        
        self.playerToken = self.playerView.observe(\.player) { [unowned self] playerView, _ in
            if let player = playerView.player {
                self.handlePlayerUpdate(player: player)
            } else {
                self.playerItemObserver?.invalidate()
                self.playerItemObserver = nil
                self.playerObserver?.invalidate()
                self.playerObserver = nil
                self.playerStallsObserver = nil
            }
        }
    }
    
    private func handlePlayerUpdate(player: AVPlayer) {
        let playerObserver = NSObjectObserver(object: player)
        self.playerObserver = playerObserver
        self.startPlayerStatusObserving(observer: playerObserver)
        self.startExternalPlaybackObserving(observer: playerObserver)
        if let playerItem = player.currentItem {
            self.startPlayerItemStatusObserving(playerItem: playerItem)
        } else {
            self.startPlayerItemObserving(observer: playerObserver)
        }
        self.startPlayerStallsObserving(player: player)
    }
    
    private func startPlayerStatusObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.status) { [unowned self] player, _ in
            if player.status == .failed {
                let message = player.error?.localizedDescription ?? "Неизвестная ошибка."
                self.statusView.showStatusInfo(message)
            } else {
                self.statusView.hideStatusInfo()
            }
        }
    }
    
    private func startExternalPlaybackObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.isExternalPlaybackActive) { [unowned self] player, _ in
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
    
    private func startPlayerItemObserving(observer: NSObjectObserver<AVPlayer>) {
        observer.startObserving(\.currentItem) { [unowned self] player, _ in
            if let playerItem = player.currentItem {
                self.startPlayerItemStatusObserving(playerItem: playerItem)
            } else {
                self.playerItemObserver?.invalidate()
                self.playerItemObserver = nil
            }
        }
    }
    
    private func startPlayerItemStatusObserving(playerItem: AVPlayerItem) {
        self.playerItemObserver = NSObjectObserver(object: playerItem)
        self.playerItemObserver?.startObserving(\.status) { [unowned self] playerItem, _ in
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
    
    public func enableRoutePickerView() {
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
    
    deinit {
        self.playerObserver?.invalidate()
        self.playerToken?.invalidate()
    }
    
    
}

