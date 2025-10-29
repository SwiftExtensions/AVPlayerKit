//
//  EdgeInsetsLabel.swift
//

import UIKit

open class EdgeInsetsLabel: UILabel {
    var insets = UIEdgeInsets.zero
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.insets))
    }
    
    open override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize.inset(by: self.insets)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size).inset(by: self.insets)
    }
    
    
}

extension CGSize {
    func inset(by insets: UIEdgeInsets) -> CGSize {
        let width = self.width + insets.left + insets.right
        let height = self.height + insets.top + insets.bottom
        
        return CGSize(width: width, height: height)
    }
    
    
}
