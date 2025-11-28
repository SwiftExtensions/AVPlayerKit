//
//  LabelView.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 28.11.2025.
//

import UIKit

/**
 Компонент для отображения изображения с текстовой меткой.
 
 `LabelView` представляет собой вертикальный `UIStackView`, содержащий `UIImageView` и `UILabel`.
 Компонент предоставляет удобный интерфейс для настройки изображения и текста через свойства.
 
 ## Пример использования:
 
 ```swift
 // Создание с изображением и заголовком
 let labelView = LabelView(
     image: UIImage(systemName: "play.circle.fill"),
     title: "Воспроизведение"
 )
 
 // Настройка внешнего вида
 labelView.textColor = .white
 labelView.font = .systemFont(ofSize: 14, weight: .medium)
 labelView.imageContentMode = .scaleAspectFit
 labelView.spacing = 8
 
 // Добавление на экран
 view.addSubview(labelView)
 ```
 
 ## Основные свойства:
 - `image` - изображение для отображения
 - `title` - текст метки
 - `textColor` - цвет текста
 - `font` - шрифт текста
 - `imageContentMode` - режим отображения изображения
 - `directionalContentInsets` - внутренние отступы содержимого
 */
open class LabelView: UIStackView {
    /**
     Компонент для отображения изображения.
     
     Доступен только для чтения. Используйте свойство `image` для установки изображения.
     */
    public lazy private(set) var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addArrangedSubview(imageView)
        
        return imageView
    }()
    /**
     Компонент для отображения текста.
     
     Доступен только для чтения. Используйте свойство `title` для установки текста.
     */
    public lazy private(set) var label: UILabel = {
        let label = UILabel()
        self.addArrangedSubview(label)
        
        return label
    }()
    
    /**
     Изображение для отображения в `imageView`.
     */
    public var image: UIImage? {
        get { self.imageView.image }
        set { self.setImageViewValue(newValue, to: \.image) }
    }
    /**
     Режим отображения содержимого изображения.
     
     Определяет, как изображение масштабируется и позиционируется внутри `imageView`.
     */
    public var imageContentMode: UIView.ContentMode {
        get { self.imageView.contentMode }
        set { self.setImageViewValue(newValue, to: \.contentMode) }
    }
    
    /**
     Текст метки для отображения в `label`.
     
     При установке нового значения автоматически вызывается `sizeToFit()` для корректного размера метки.
     */
    public var title: String? {
        get { self.label.text }
        set {
            self.setLabelValue(newValue, to: \.text)
            self.label.sizeToFit()
        }
    }
    /**
     Цвет текста метки.
     */
    public var textColor: UIColor? {
        get { self.label.textColor }
        set { self.setLabelValue(newValue, to: \.textColor) }
    }
    /**
     Выравнивание текста в метке.
     */
    public var textAlignment: NSTextAlignment {
        get { self.label.textAlignment }
        set { self.setLabelValue(newValue, to: \.textAlignment) }
    }
    /**
     Шрифт текста метки.
     */
    public var font: UIFont? {
        get { self.label.font }
        set { self.setLabelValue(newValue, to: \.font) }
    }
    /**
     Максимальное количество строк для отображения текста.
     
     Значение `0` означает отсутствие ограничений по количеству строк.
     */
    public var numberOfLines: Int {
        get { self.label.numberOfLines }
        set { self.setLabelValue(newValue, to: \.numberOfLines) }
    }
    /**
     Внутренние отступы содержимого с поддержкой направления текста (RTL/LTR).
     
     Использует `directionalLayoutMargins` для корректного отображения
     в языках с направлением справа налево.
     
     ## Пример использования:
     
     ```swift
     labelView.directionalContentInsets = NSDirectionalEdgeInsets(
         top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0
     )
     ```
     
     - Note: При установке значения автоматически включается `isLayoutMarginsRelativeArrangement`.
     */
    public var directionalContentInsets: NSDirectionalEdgeInsets {
        get { self.directionalLayoutMargins }
        set {
            self.directionalLayoutMargins = newValue
            self.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    /**
     Создает экземпляр `LabelView` с изображением и заголовком.
     
     - Parameters:
       - image: Изображение для отображения. Может быть `nil`.
       - title: Текст метки. Может быть `nil`.
     
     Инициализатор автоматически настраивает вертикальную ориентацию,
     отступ 4.0 и центрирование элементов.
     */
    public convenience init(image: UIImage?, title: String?) {
        self.init(frame: .zero)
        
        self.setImageViewValue(image, to: \.image)
        self.setLabelValue(title, to: \.text)
    }
    /**
     Создает экземпляр `LabelView` с указанным фреймом.
     
     - Parameter frame: Прямоугольник, определяющий размер и позицию view.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialSetup()
    }
    /**
     Создает экземпляр `LabelView` из Interface Builder.
     
     - Parameter coder: Объект для декодирования view.
     */
    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    /**
     Установить начальные настройки.В
     */
    private func initialSetup() {
        self.axis = .vertical
        self.spacing = 4.0
        self.alignment = .center
    }
    
    /**
     Устанавливает значение свойства для `imageView` через KeyPath.
     
     - Parameters:
       - value: Значение для установки.
       - keyPath: KeyPath к свойству `imageView`.
     */
    private func setImageViewValue<Value>(
        _ value: Value,
        to keyPath: WritableKeyPath<UIImageView, Value>
    ) {
        self.imageView[keyPath: keyPath] = value
    }
    /**
     Устанавливает значение свойства для `label` через KeyPath.
     
     - Parameters:
       - value: Значение для установки.
       - keyPath: KeyPath к свойству `label`.
     */
    private func setLabelValue<Value>(
        _ value: Value,
        to keyPath: WritableKeyPath<UILabel, Value>
    ) {
        self.label[keyPath: keyPath] = value
    }
    
    
}
