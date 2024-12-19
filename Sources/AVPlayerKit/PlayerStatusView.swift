//
//  PlayerStatusView.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import UIKit

/**
 Представление для отображения текущего состояния плеера.
 */
public class PlayerStatusView: UIView {
    public private(set) lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .white)
        }
        indicator.color = .white
        
        return indicator
    }()
    
    public private(set) lazy var infoLabel: EdgeInsetsLabel = {
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
        self.isUserInteractionEnabled = false
        
        [self.loadingIndicator, self.infoLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            self.infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.infoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.infoLabel.widthAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.widthAnchor,
                constant: -80.0
            ),
            self.infoLabel.heightAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.heightAnchor,
                constant: -80.0
            ),
        ])
    }
    
    func startLoadingAnimation() {
        self.loadingIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
        self.loadingIndicator.stopAnimating()
    }
    
    func showStatusInfo(_ message: String) {
        self.infoLabel.text = message
        self.infoLabel.isHidden = false
    }
    
    func hideStatusInfo() {
        self.infoLabel.text = nil
        self.infoLabel.isHidden = true
    }
    
    
}
