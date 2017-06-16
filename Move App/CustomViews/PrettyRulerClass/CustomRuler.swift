//
//  CustomRuler.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


let interval:UInt = 15

public class CustomRuler: UIView {
    
    public var selectValue: ((UInt) ->())?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public func showRuler(with maxCount: UInt,currentValue: UInt) {
        
        for vw in self.subviews {
            if vw is RulerScroll {
                vw.removeFromSuperview()
            }
        }
        
        let scroll = RulerScroll(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        scroll.delegate = self
        scroll.showsHorizontalScrollIndicator = false
        scroll.maxValue = maxCount
        
        scroll.contentSize = CGSize(width: self.frame.size.width + CGFloat(interval*maxCount), height: 100)
        
        let value = currentValue > maxCount ? maxCount:currentValue
        UIView.animate(withDuration: 0.3) {
            scroll.setContentOffset(CGPoint(x: Int(value*interval), y: 0), animated: true)
        }
        
        
        scroll.drawRuler()
        
        self.addSubview(scroll)
    }
    
}


extension CustomRuler:UIScrollViewDelegate {
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let offset = scrollView.contentOffset.x <= 0 ? 0:scrollView.contentOffset.x
            let value  = UInt(offset/CGFloat(interval))
            scrollView.setContentOffset(CGPoint(x: Int(value*interval), y: 0), animated: true)
            if  let sel = self.selectValue {
                sel(value)
            }
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x <= 0 ? 0:scrollView.contentOffset.x
        let value  = UInt(offset/CGFloat(interval))
        scrollView.setContentOffset(CGPoint(x: Int(value*interval), y: 0), animated: true)
        if  let sel = self.selectValue {
            sel(value)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x <= 0 ? 0:scrollView.contentOffset.x
        let value  = UInt(offset/CGFloat(interval))
        scrollView.setContentOffset(CGPoint(x: Int(value*interval), y: 0), animated: true)
        if let sel = self.selectValue {
            sel(value)
        }
    }
    

}



