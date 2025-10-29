//
//  UIView.swift
//  AVPlayerKit
//
//  Created by Алгашев Александр on 19.12.2024.
//

import UIKit

extension UIView {
    func insert(into superview: UIView) {
        superview.addSubview(self)
        self.frame = superview.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    
}
