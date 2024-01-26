//
//  PlayerView.swift
//  

import UIKit
import AVKit

/**
 Подкласс
 [UIView](https://developer.apple.com/documentation/uikit/uiview)
 поддерживаемый слоем
 [AVPlayerLayer](https://developer.apple.com/documentation/avfoundation/avplayerlayer).
 
 Дополнительную информацию см.:
 [Creating a Movie Player App with Basic Playback Controls](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_movie_player_app_with_basic_playback_controls).
 */
open class PlayerView: UIView {
    @objc public dynamic var player: AVPlayer? {
        get { self.playerLayer.player }
        set { self.playerLayer.player = newValue }
    }

    public var playerLayer: AVPlayerLayer {
        self.layer as! AVPlayerLayer
    }

    public override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    /**
     A view that presents a list of nearby media receivers.
     */
    public var routePickerView: AVRoutePickerView = {
        let view = AVRoutePickerView()
        view.backgroundColor = .black.withAlphaComponent(0.65)
        view.tintColor = .white
        view.layer.cornerRadius = 8.0
        
        return view
    }()
    
    public var loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .white)
        }
        indicator.color = .white
        
        return indicator
    }()
    
    public var infoLabel: EdgeInsetsLabel = {
        let label = EdgeInsetsLabel()
        if #available(iOS 13.0, *) {
            label.textColor = .systemBackground
            label.backgroundColor = .label
        } else {
            label.textColor = .white
            label.backgroundColor = .black
        }
        label.layer.cornerRadius = 8.0
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.insets = UIEdgeInsets(
            top: 4.0,
            left: 6.0,
            bottom: 4.0,
            right: 6.0
        )
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
//        label.adjustsFontForContentSizeCategory = true
        label.isHidden = true
        
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetup()
    }
    
    private func initialSetup() {
        [self.routePickerView, self.loadingIndicator, self.infoLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        NSLayoutConstraint.activate([
            self.routePickerView.widthAnchor.constraint(equalTo: self.routePickerView.heightAnchor),
            self.routePickerView.leftAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leftAnchor,
                constant: 8.0),
            self.routePickerView.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor,
                constant: 8.0),
            
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.infoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.infoLabel.widthAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.widthAnchor,
                constant: -80.0),
            self.infoLabel.heightAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.heightAnchor,
                constant: -80.0),
        ])
    }
    
    
}
