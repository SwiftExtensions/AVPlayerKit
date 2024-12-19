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
     A view that presents a list of nearby media receivers.
     */
    public private(set) lazy var routePickerView: AVRoutePickerView = {
        let view = AVRoutePickerView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        view.tintColor = .white
        view.layer.cornerRadius = 8.0
        
        return view
    }()
    
    func setupRoutePickerView() {
        self.routePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.routePickerView)
        
        NSLayoutConstraint.activate([
            self.routePickerView.widthAnchor.constraint(equalTo: self.routePickerView.heightAnchor),
            self.routePickerView.leftAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leftAnchor,
                constant: 8.0
            ),
            self.routePickerView.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: 8.0
            ),
        ])
    }
    
    
}
