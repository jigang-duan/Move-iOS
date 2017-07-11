//
//  CPinchGuesture.swift
//  Move App
//
//  Created by LX on 2017/7/4.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CPinchGuesture :UIPinchGestureRecognizer {
    
    func canBePreventedByGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
    
    func canPreventGestureRecognizer(_ gestureRecognizer:UIGestureRecognizer) ->Bool{
        return false
    }
}
