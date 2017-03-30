//
//  Rx+UIButton.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/29.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    
    var enabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { button, enabled in
            button.isEnabled = enabled
            button.alpha = enabled ? 1.0 : 0.5
        }
    }
}
