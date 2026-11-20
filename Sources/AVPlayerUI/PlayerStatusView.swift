//
//  PlayerStatusView.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import ActivityLabel
import UIKit

/**
 Представление для отображения текущего состояния плеера.
 */
public class PlayerStatusView: UIView {
    public private(set) lazy var infoLabel: LabelView = {
        let label = LabelView(image: nil, title: nil)
        label.spacing = 12.0
        label.tintColor = .white
        label.textColor = .white
        label.background = self.infoBackground
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.directionalContentInsets = NSDirectionalEdgeInsets(
            top:      16.0,
            leading:  16.0,
            bottom:   16.0,
            trailing: 16.0
        )
//        label.adjustsFontForContentSizeCategory = true
        label.activityView.color = .white
        label.isHidden = true
        
        return label
    }()
    /**
     Фон информационной метки.
     */
    private let infoBackground: UIBackgroundConfiguration = {
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .black
        background.cornerRadius = 12.0

        return background
    }()
    /**
     Признак отображения фона у информационной метки.

     Фон отображается только при наличии содержимого:
     текста или изображения. При отображении одного
     индикатора загрузки фон отключён.
     Значение по умолчанию — `true`.
     */
    /**
     Признак отображения фона у индикатора загрузки.

     Применяется, когда метка отображает только индикатор
     без содержимого. Значение по умолчанию — `true`.
     */
    var showsLoadingIndicatorBackground = true

    
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
        
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.infoLabel)
        NSLayoutConstraint.activate([
            self.infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.infoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.infoLabel.widthAnchor.constraint(
                lessThanOrEqualTo: self.widthAnchor,
                multiplier: 0.75
            ),
            self.infoLabel.heightAnchor.constraint(
                lessThanOrEqualTo: self.heightAnchor,
                constant: -80.0
            ),
        ])
    }
    
    func startLoadingAnimation() {
        self.infoLabel.background = self.showsLoadingIndicatorBackground
            ? self.infoBackground
            : nil
        self.infoLabel.startActivityAnimating()
    }
    
    func stopLoadingAnimation() {
        self.infoLabel.stopActivityAnimating()
    }
    
    /**
     Отображает информацию о состоянии плеера.
     
     - Parameters:
       - image: Изображение статуса.
       - title: Текст статуса.
       - animated: Признак анимированного появления метки.
       При `true` для скрытой метки содержимое проявляется
       с одновременным увеличением из уменьшенного размера.
       Для видимой метки текущее содержимое растворяется,
       после чего новое проявляется. Значение по умолчанию — `false`.
     */
    func showStatusInfo(
        image: UIImage?,
        title: String?,
        animated: Bool = false
    ) {
        self.infoLabel.background = self.infoBackground
        self.infoLabel.show(image: image, title: title, animated: animated)
    }
    /**
     Скрывает информацию о состоянии плеера.
     
     - Parameter animated: Признак анимированного скрытия метки.
     При `true` метка уменьшается и растворяется.
     Значение по умолчанию — `false`.
     */
    func hideStatusInfo(animated: Bool = false) {
        self.infoLabel.hide(animated: animated)
    }
    
    
}
