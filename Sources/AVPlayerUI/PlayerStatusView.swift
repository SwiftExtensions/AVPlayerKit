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
    
    /**
     Направляющая области статуса для привязки метки.

     Ограничения к направляющей активируются при добавлении
     представления в иерархию: на момент инициализации
     представление ещё не имеет общего предка
     с владельцем направляющей.
     */
    private weak var statusLayoutGuide: UILayoutGuide?
    
    /**
     Фон информационной метки.
     */
    private let infoBackground: UIBackgroundConfiguration = {
        var background = UIBackgroundConfiguration.clear()
        background.backgroundColor = .black
        background.cornerRadius = 12.0

        return background
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }

    /**
     Создаёт представление статуса, привязанное к области статуса.

     Привязка применяется при добавлении представления
     в иерархию: верхний край информационной метки совпадает
     с верхним краем направляющей, нижний край — не ниже
     нижнего края направляющей. Низкоприоритетное
     центрирование метки уступает привязке к направляющей.

     - Parameter layoutGuide: Направляющая области статуса.
     */
    init(statusLayoutGuide layoutGuide: UILayoutGuide) {
        super.init(frame: .zero)
        self.statusLayoutGuide = layoutGuide
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
        let centerYConstraint = self.infoLabel.centerYAnchor.constraint(
            equalTo: self.centerYAnchor
        )
        centerYConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            self.infoLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerYConstraint,
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
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let statusLayoutGuide else { return }
        
        self.statusLayoutGuide = nil
        NSLayoutConstraint.activate([
            self.infoLabel.topAnchor.constraint(
                equalTo: statusLayoutGuide.topAnchor
            ),
            self.infoLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: statusLayoutGuide.bottomAnchor
            ),
        ])
    }
    
    func startLoadingAnimation() {
        let showsBackground = self.showsLoadingIndicatorBackground
        self.infoLabel.background = showsBackground ? self.infoBackground : nil
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
