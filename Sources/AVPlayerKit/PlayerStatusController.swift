//
//  PlayerStatusController.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 18.11.2026.
//

import UIKit

/**
 Контроллер отображения статуса плеера.

 Управляет ``PlayerStatusView`` и определяет, какое содержимое
 отображает информационная метка: статус загрузки или
 информационное сообщение. Статус загрузки не вытесняет
 отображаемое сообщение.
 */
class PlayerStatusController {
    /**
     Содержимое информационной метки.
     */
    private enum StatusInfoContent {
        /**
         Метка не отображает содержимое.
         */
        case none
        /**
         Отображается статус загрузки.
         */
        case loading
        /**
         Отображается информационное сообщение.
         */
        case message


    }
    
    /**
     Вариант отображения статуса загрузки.

     Значение по умолчанию — ``PlayerViewController/LoadingDisplayStyle/detailed``.
     */
    var loadingDisplayStyle: PlayerViewController.LoadingDisplayStyle = .detailed {
        didSet {
            self.statusView.showsLoadingIndicatorBackground =
                self.loadingDisplayStyle != .indicator
        }
    }
    
    /**
     Представление статуса, которым управляет контроллер.
     */
    private let statusView: PlayerStatusView
    
    /**
     Содержимое, отображаемое в информационной метке.
     */
    private var statusInfoContent: StatusInfoContent = .none

    /**
     Создает контроллер отображения статуса.
     - Parameter statusView: Представление статуса.
     */
    init(statusView: PlayerStatusView) {
        self.statusView = statusView
    }

    /**
     Отображает информационное сообщение.
     - Parameter image: Изображение сообщения.
     - Parameter title: Текст сообщения.
     - Parameter animated: Признак анимированного отображения.
     */
    func showMessage(
        image: UIImage?,
        title: String?,
        animated: Bool = false
    ) {
        self.statusInfoContent = .message
        self.statusView.showStatusInfo(
            image: image,
            title: title,
            animated: animated
        )
    }
    /**
     Скрывает информацию о состоянии плеера.

     - Parameter animated: Признак анимированного скрытия метки.
     */
    func hideStatusInfo(animated: Bool = false) {
        self.statusInfoContent = .none
        self.statusView.hideStatusInfo(animated: animated)
    }
    /**
     Применяет изменение статуса загрузки.

     Статус загрузки применяется к метке, только если она
     не занята информационным сообщением.

     - Parameter status: Статус загрузки.
     */
    func handleLoadingStatus(_ status: PlayerLoadingStatusObserver.Status) {
        switch status {
        case .stalled:
            guard self.loadingDisplayStyle != .hidden,
                  self.statusInfoContent != .message else { return }
            self.statusInfoContent = .loading
            self.statusView.startLoadingAnimation()
        case .loading(let info):
            guard self.loadingDisplayStyle == .detailed,
                  self.statusInfoContent == .loading else { return }
            let animated = self.statusView.infoLabel.title == nil
            self.statusView.showStatusInfo(
                image: nil,
                title: info,
                animated: animated
            )
        case .finished:
            guard self.statusInfoContent != .message else { return }
            self.hideStatusInfo(animated: true)
        case .interrupted:
            if self.statusInfoContent == .loading {
                self.statusInfoContent = .none
            }
            self.statusView.stopLoadingAnimation()
        }
    }


}
