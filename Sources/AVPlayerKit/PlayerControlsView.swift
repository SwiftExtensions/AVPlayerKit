//
//  PlayerControlsView.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import AVKit
import UIKit

/**
 Представление с элементами управления плеера.
 */
public class PlayerControlsView: UIView {
    /**
     Представление, отображающее список доступных медиаприёмников.
     */
    public private(set) lazy var routePickerView: AVRoutePickerView = {
        let view = AVRoutePickerView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        view.tintColor = .white
        view.layer.cornerRadius = 8.0
        
        return view
    }()
    /**
     Кнопка управления режимом «картинка в картинке».
     */
    public private(set) lazy var pipButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.65)
        button.tintColor = .white
        button.layer.cornerRadius = 8.0
        let startImage = AVPictureInPictureController.pictureInPictureButtonStartImage
        let stopImage = AVPictureInPictureController.pictureInPictureButtonStopImage
        button.setImage(startImage, for: .normal)
        button.setImage(stopImage, for: .selected)
        
        return button
    }()
    
    /**
     Настраивает `routePickerView` и добавляет представление в иерархию при отсутствии.
     */
    func setupRoutePickerView() {
        if self.subviews.contains(self.routePickerView) { return }
        
        self.routePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.routePickerView)
        
        NSLayoutConstraint.activate([
            self.routePickerView.heightAnchor.constraint(equalToConstant: 34.0),
            self.routePickerView.widthAnchor.constraint(
                equalTo: self.routePickerView.heightAnchor
            ),
            self.routePickerView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: 8.0
            ),
            self.routePickerView.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: 8.0
            ),
        ])
    }
    /**
     Настраивает `pipButton` и добавляет кнопку в иерархию при отсутствии.
     */
    func setupPiPButton() {
        if self.subviews.contains(self.pipButton) { return }
        
        self.pipButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.pipButton)
        
        NSLayoutConstraint.activate([
            self.pipButton.heightAnchor.constraint(equalToConstant: 34.0),
            self.pipButton.widthAnchor.constraint(
                equalTo: self.pipButton.heightAnchor
            ),
            self.pipButton.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -8.0
            ),
            self.pipButton.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: 8.0
            ),
        ])
    }
    
    
}
