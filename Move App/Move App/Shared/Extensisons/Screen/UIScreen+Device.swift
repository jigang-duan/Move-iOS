//
//  UIScreen+Device.swift
//  Move App
//
//  Created by jiang.duan on 2017/6/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation


extension UIScreen {
    
    var isPhone: Bool {
        return UI_USER_INTERFACE_IDIOM() == .phone
    }
    
    var isPad: Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    private var maxLength: CGFloat {
        return CGFloat.maximum(bounds.size.width, bounds.size.height)
    }
    
    var isIPhone4OrLess: Bool {
        return isPhone && (maxLength < 568.0)
    }
    
    var isIPhone5: Bool {
        return isPhone && (maxLength == 568.0)
    }
    
    var isIPhone6: Bool {
        return isPhone && (maxLength == 667.0)
    }
    
    var isIPhone6P: Bool {
        return isPhone && (maxLength == 736.0)
    }
    
    var isIPhone5OrLess: Bool {
        return isPhone && (maxLength <= 568.0)
    }
    
    var isIPhone6OrLess: Bool {
        return isPhone && (maxLength <= 667.0)
    }
    
    var isIPhone6POrLess: Bool {
        return isPhone && (maxLength <= 736.0)
    }
}
