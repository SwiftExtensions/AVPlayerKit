//
//  LabelView.swift
//  AVPlayerKit
//
//  Created by Александр Алгашев on 28.11.2025.
//

import UIKit

/**
 Компонент для отображения изображения с текстовой меткой.

 `LabelView` — вертикальный стек, содержащий ``activityView``
 и отдельный стек содержимого ``LabelContentView`` из `UIImageView`
 и `UILabel`.

 Изображение и текст объединены в отдельный стек, поэтому
 анимируются как единое целое.

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
 - `activityView` - индикатор загрузки
 */
open class LabelView: UIStackView {
    /**
     Индикатор загрузки `UIActivityIndicatorView`, встроенный в метку.

     Располагается первым элементом стека над остальным содержимым.
     Пока анимация не запущена, индикатор скрыт
     и не занимает места в стеке.
     */
    public private(set) var activityView: UIActivityIndicatorView!
    /**
     Стек содержимого из изображения и текста.
     */
    private(set) var contentView: LabelContentView!
    /**
     Компонент для отображения изображения.

     Доступен только для чтения. Используйте свойство `image` для установки изображения.
     */
    public var imageView: UIImageView! { self.contentView.imageView }
    /**
     Компонент для отображения текста.

     Доступен только для чтения. Используйте свойство `title` для установки текста.
     */
    public var label: UILabel! { self.contentView.label }

    /**
     Отступ между элементами стека.

     Применяется и между элементами внутри стека содержимого.
     */
    public override var spacing: CGFloat {
        get { super.spacing }
        set {
            super.spacing = newValue
            self.contentView?.spacing = newValue
        }
    }
    /**
     Изображение для отображения в `imageView`.
     */
    public var image: UIImage? {
        get { self.imageView.image }
        set { self.imageView.image = newValue }
    }
    /**
     Режим отображения содержимого изображения.

     Определяет, как изображение масштабируется и позиционируется внутри `imageView`.
     */
    public var imageContentMode: UIView.ContentMode {
        get { self.imageView.contentMode }
        set { self.imageView.contentMode = newValue }
    }

    /**
     Текст метки для отображения в `label`.

     Размер и положение метки управляются autolayout,
     например ограничениями `UIStackView`.
     */
    public var title: String? {
        get { self.label.text }
        set { self.label.text = newValue }
    }
    /**
     Цвет текста метки.
     */
    public var textColor: UIColor? {
        get { self.label.textColor }
        set { self.label.textColor = newValue }
    }
    /**
     Выравнивание текста в метке.
     */
    public var textAlignment: NSTextAlignment {
        get { self.label.textAlignment }
        set { self.label.textAlignment = newValue }
    }
    /**
     Шрифт текста метки.
     */
    public var font: UIFont? {
        get { self.label.font }
        set { self.label.font = newValue }
    }
    /**
     Максимальное количество строк для отображения текста.

     Значение `0` означает отсутствие ограничений по количеству строк.
     */
    public var numberOfLines: Int {
        get { self.label.numberOfLines }
        set { self.label.numberOfLines = newValue }
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
            self.insetsLayoutMarginsFromSafeArea = false
            self.directionalLayoutMargins = newValue
            self.isLayoutMarginsRelativeArrangement = true
        }
    }

    /**
     Создает экземпляр `LabelView` с изображением и заголовком.

     - Parameter image: Изображение для отображения. Может быть `nil`.
     - Parameter title: Текст метки. Может быть `nil`.

     Инициализатор автоматически настраивает вертикальную ориентацию,
     отступ 4.0 и центрирование элементов.
     */
    public convenience init(image: UIImage?, title: String?) {
        self.init(frame: .zero)

        self.contentView.image = image
        self.contentView.title = title
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
        self.initialSetup()
    }
    /**
     Установить начальные настройки.
     */
    private func initialSetup() {
        self.axis = .vertical
        self.spacing = 4.0
        self.alignment = .center

        let activityView = UIActivityIndicatorView(style: .medium)
        self.activityView = activityView
        self.insertArrangedSubview(activityView, at: 0)

        let contentView = LabelContentView()
        self.contentView = contentView
        self.addArrangedSubview(contentView)
    }
    /**
     Запускает анимацию ``activityView`` и отображает метку.
     */
    public func startActivityAnimation() {
        self.isHidden = false
        self.activityView.alpha = 1.0
        self.activityView.startAnimating()
    }
    /**
     Останавливает анимацию ``activityView``.

     Индикатор плавно затухает на месте, после чего
     освобождает занимаемое место.
     */
    public func stopActivityAnimation() {
        guard self.activityView.isAnimating else { return }

        UIView.animate(withDuration: 0.25) {
            self.activityView.alpha = 0.0
        } completion: { _ in
            self.activityView.stopAnimating()
            self.activityView.alpha = 1.0
        }
    }
    /**
     Отображает содержимое метки.

     - Parameter image: Изображение.
     - Parameter title: Текст.
     - Parameter animated: Признак анимированного отображения.
       При `true` для скрытой метки содержимое проявляется
       через изменение прозрачности. Для видимой метки текущие
       изображение и текст растворяются, после чего новые
       проявляются. ``activityView`` при этом остаётся
       видимым. Значение по умолчанию — `false`.
     */
    public func show(
        image: UIImage?,
        title: String?,
        animated: Bool = false
    ) {
        guard animated else {
            self.contentView.image = image
            self.contentView.title = title
            self.contentView.resetAppearance()
            self.alpha = 1.0
            self.isHidden = false
            return
        }

        if self.isHidden {
            self.contentView.image = image
            self.contentView.title = title
            self.contentView.resetAppearance()
            self.contentView.alpha = 0.0
            self.alpha = 1.0
            UIView.animate(withDuration: 0.35) {
                self.isHidden = false
                self.contentView.alpha = 1.0
            }
        } else {
            self.replaceContent(with: image, title: title)
        }
    }
    /**
     Заменяет содержимое метки с анимацией.

     Текущие изображение и текст растворяются, затем
     устанавливаются новые и проявляются.
     */
    private func replaceContent(with image: UIImage?, title: String?) {
        UIView.animate(withDuration: 0.3) {
            self.contentView.alpha = 0.0
        } completion: { finished in
            guard finished else { return }
            self.contentView.image = image
            self.contentView.title = title
            UIView.animate(withDuration: 0.35) {
                self.contentView.alpha = 1.0
            }
        }
    }
    /**
     Скрывает метку.

     ``activityView`` при скрытии останавливается.

     - Parameter animated: Признак анимированного скрытия.
       При `true` содержимое уменьшается и растворяется.
       Значение по умолчанию — `false`.
     */
    public func hide(animated: Bool = false) {
        guard animated else {
            self.contentView.clear()
            self.contentView.resetAppearance()
            self.activityView.stopAnimating()
            self.isHidden = true
            return
        }

        if self.isHidden {
            self.activityView.stopAnimating()
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.0
            self.contentView.transform = CGAffineTransform(
                scaleX: 0.75,
                y: 0.75
            )
        } completion: { _ in
            self.isHidden = true
            self.alpha = 1.0
            self.contentView.clear()
            self.contentView.resetAppearance()
            // Индикатор останавливается после скрытия метки,
            // чтобы схлопывание места не было видно.
            self.activityView.stopAnimating()
        }
    }
    /**
     Очищает содержимое метки.

     Сбрасывает изображение и текст.
     */
    public func clear() {
        self.contentView.clear()
    }


}
