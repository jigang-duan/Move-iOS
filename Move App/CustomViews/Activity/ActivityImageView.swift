//
//  ActivityImageView.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

public class ActivityImageView: UIImageView {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func startAnimating() {
        let animation = CAAnimationGroup()
        animation.duration = 0.8
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let rotatingAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotatingAnimation.fromValue = 0.0
        rotatingAnimation.toValue = 2 * Double.pi
        rotatingAnimation.autoreverses = false
        rotatingAnimation.fillMode = kCAFillModeForwards
        
        animation.animations = [rotatingAnimation]
        
        layer.add(animation, forKey: "rotating")
    }
    
    override public func stopAnimating() {
        layer.removeAnimation(forKey: "rotating")
    }
    
    override public var isAnimating: Bool {
        return layer.animationKeys()?.filter{ $0 == "rotating" }.first != nil
    }

}
