//
//  AVRoutePickerController.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 13.10.2025.
//

import AVKit

public extension AVRoutePickerView {
    /**
     События взаимодействия с `AVRoutePickerView`.
     */
    enum Event {
        /**
         Событие, возникающее перед отображением списка доступных маршрутов.
         */
        case willBeginPresentingRoutes
        /**
         Событие, возникающее после закрытия списка доступных маршрутов.
         */
        case didEndPresentingRoutes
        
        
    }
    
    
}

/**
 Обёртка над `AVRoutePickerView` с возможностью установки действий на события отображения маршрутов.
 */
final class AVRoutePickerController: NSObject {
    /**
     Тип блока, вызываемого при возникновении события `AVRoutePickerView`.
     - Parameter pickerView: Представление выбора маршрута, для которого сработало событие.
     */
    typealias Action = (_ pickerView: AVRoutePickerView) -> Void
    
    /**
     Словарь зарегистрированных действий для событий `AVRoutePickerView`.
     */
    private var actions: [AVRoutePickerView.Event : Action] = [:]
    
    /**
     Лениво создаваемое представление выбора маршрута.
     */
    weak var routePickerView: AVRoutePickerView? {
        didSet { self.routePickerView?.delegate = self }
    }
    
    /**
     Признак наличия нескольких доступных маршрутов воспроизведения.
     */
    var multipleRoutesDetected: Bool {
        let detector = AVRouteDetector()
        detector.isRouteDetectionEnabled = true
        defer { detector.isRouteDetectionEnabled = false }
        
        return detector.multipleRoutesDetected
    }
    
    /**
     Добавляет обработчик для указанного события `AVRoutePickerView`.
     - Parameter controlEvents: Событие, для которого необходимо выполнить действие.
     - Parameter block: Действие, выполняемое при возникновении события.
     */
    func addAction(
        for controlEvents: AVRoutePickerView.Event,
        using block: @escaping Action
    ) {
        self.actions[controlEvents] = block
    }
    
    
}

// MARK: - AVRoutePickerViewDelegate

extension AVRoutePickerController: AVRoutePickerViewDelegate {
    /**
     Вызывается перед отображением списка маршрутов и выполняет зарегистрированное действие.
     - Parameter routePickerView: Представление выбора маршрута, инициирующее событие.
     */
    public func routePickerViewWillBeginPresentingRoutes(
        _ routePickerView: AVRoutePickerView
    ) {
        self.actions[.willBeginPresentingRoutes]?(routePickerView)
    }
    
    /**
     Вызывается после закрытия списка маршрутов и выполняет зарегистрированное действие.
     - Parameter routePickerView: Представление выбора маршрута, инициирующее событие.
     */
    public func routePickerViewDidEndPresentingRoutes(
        _ routePickerView: AVRoutePickerView
    ) {
        self.actions[.didEndPresentingRoutes]?(routePickerView)
    }
    
    
}
