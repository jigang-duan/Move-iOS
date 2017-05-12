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
import CustomViews
import Kingfisher

extension Reactive where Base: UIButton {
    
    var enabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { button, enabled in
            button.isEnabled = enabled
            button.alpha = enabled ? 1.0 : 0.5
        }
    }
    
}

extension Reactive where Base: UIButton {
    
    var initialsAvatar: UIBindingObserver<Base, (URL?, String)> {
        return UIBindingObserver(UIElement: self.base) { (button, value) in
            let imgURL = value.0
            let name = value.1
            let placeImg = CDFInitialsAvatar(rect: button.bounds, fullName: name ).imageRepresentation()!
            let _button = button as UIButton
            _button.kf.setBackgroundImage(with: imgURL, for: .normal, placeholder: placeImg)
        }
    }
    
}
