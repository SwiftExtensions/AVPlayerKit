//
//  LabelContentView.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 17.11.2026.
//

import UIKit

/**
 Стек для отображения изображения и текста.

 Объединяет `UIImageView` и `UILabel` в вертикальный стек
 и хранит визуальное состояние содержимого. Анимациями
 и раскладкой управляет ``LabelView``.
 */
class LabelContentView: UIStackView {
    /**
     Компонент для отображения изображения.
     */
    let imageView: UIImageView
    /**
     Компонент для отображения текста.
     */
    let label: UILabel

    /**
     Изображение для отображения в `imageView`.
     */
    var image: UIImage? {
        get { self.imageView.image }
        set { self.imageView.image = newValue }
    }
    /**
     Текст метки для отображения в `label`.
     */
    var title: String? {
        get { self.label.text }
        set { self.label.text = newValue }
    }

    /**
     Создает стек содержимого с указанным фреймом.

     - Parameter frame: Прямоугольник, определяющий размер и позицию view.
     */
    override init(frame: CGRect) {
        let imageView = UIImageView()
        self.imageView = imageView

        let label = UILabel()
        self.label = label

        super.init(frame: frame)
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 4.0
        self.addArrangedSubview(imageView)
        self.addArrangedSubview(label)
    }
    /**
     Создает стек содержимого из Interface Builder.

     - Parameter coder: Объект для декодирования view.
     */
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Очищает содержимое.

     Сбрасывает изображение и текст.
     */
    func clear() {
        self.image = nil
        self.title = nil
    }
    /**
     Сбрасывает визуальное состояние содержимого.
     */
    func resetAppearance() {
        self.alpha = 1.0
        self.transform = .identity
    }


}
