//
//  CollapsibleStackView.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import UIKit

/**
 Стек с единственным вложенным представлением.

 Скрытие исключает вложенное представление из раскладки —
 высота стека схлопывается до нуля.
 */
public final class CollapsibleStackView: UIStackView {
    /**
     Вложенное представление.

     Единственный элемент стека: его скрытие
     схлопывает высоту стека до нуля.
     */
    public let contentView = UIView()

    /**
     Признак скрытия вложенного представления.

     Переадресуется `contentView`: скрытый элемент
     исключается стеком из раскладки.
     */
    public override var isHidden: Bool {
        get { self.contentView.isHidden }
        set { self.contentView.isHidden = newValue }
    }


    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
        self.addArrangedSubview(self.contentView)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }


}
