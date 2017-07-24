//
//  Rx+Badge.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews

extension Reactive where Base: UIView {
    
    var showBadge: UIBindingObserver<Base, CGPoint?> {
        return UIBindingObserver(UIElement: self.base) { view, point in
            view.badge.show(at: point)
        }
    }
    
    var isBadgeHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.badge.isHidden = hidden
        }
    }
    
    var badgeCount: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { view, count in
            view.badge.count = count
        }
    }
    
    var isLeftBadgeHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.badge.isLeftHidden = hidden
        }
    }
    
    var isRightBadgeHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { view, hidden in
            view.badge.isRightHidden = hidden
        }
    }
}
