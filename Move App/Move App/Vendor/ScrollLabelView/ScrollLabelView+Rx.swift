//
//  ScrollLabelView+Rx.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: ScrollLabelView {
    var text: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: self.base) { label, str in
            label.text = str
        }
    }
}
