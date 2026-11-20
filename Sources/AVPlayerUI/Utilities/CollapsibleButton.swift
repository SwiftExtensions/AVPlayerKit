//
//  CollapsibleButton.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import UIKit

/**
 Кнопка, сворачивающая свою высоту при скрытии.

 Размещает себя во вложенном представлении `stackView`:
 в иерархию добавляется `stackView`, скрытие кнопки
 схлопывает высоту стека до нуля.
 */
public final class CollapsibleButton: UIButton {
    /**
     Стек-обёртка кнопки.

     Встраивается в иерархию вместо самой кнопки:
     кнопка находится во вложенном представлении
     с отступами `directionalLayoutMargins`.
     */
    public let stackView = CollapsibleStackView()

    /**
     Признак скрытия кнопки.

     Переадресуется `stackView`: скрытие исключает
     кнопку с отступами из раскладки — высота стека
     схлопывается до нуля.
     */
    public override var isHidden: Bool {
        get { self.stackView.isHidden }
        set { self.stackView.isHidden = newValue }
    }

    /**
     Внутренние отступы вокруг кнопки.

     Переадресуется вложенному представлению `stackView`:
     кнопка привязана к его `layoutMarginsGuide`, поэтому
     поля контейнера образуют отступы вокруг кнопки.
     */
    public override var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { self.stackView.contentView.directionalLayoutMargins }
        set {
            self.stackView.contentView.directionalLayoutMargins = newValue
            let width = newValue.leading + newValue.trailing
            self.stackWidthConstraint.constant = width
        }
    }

    /**
     Ограничение ширины стека.

     Фиксирует ширину стека шириной кнопки
     с горизонтальными отступами: без ограничения ширина
     стека схлопывается вместе с высотой и при появлении
     кнопки её кадр анимированно смещается по горизонтали.
     */
    private lazy var stackWidthConstraint: NSLayoutConstraint = {
        self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor)
    }()


    public init() {
        super.init(frame: .zero)
        self.initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     Выполняет начальную настройку кнопки:

     размещает кнопку во вложенном представлении `stackView`
     по его `layoutMarginsGuide` и скрывает её.
     */
    private func initialSetup() {
        self.directionalLayoutMargins = .zero
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.contentView.addSubview(self)
        let marginsGuide = self.stackView.contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: marginsGuide.topAnchor),
            self.bottomAnchor.constraint(equalTo: marginsGuide.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
            self.stackWidthConstraint,
        ])

        self.isHidden = true
    }


}
