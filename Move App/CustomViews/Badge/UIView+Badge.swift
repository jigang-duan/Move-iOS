//
//  UIView+Badge.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

public final class Badge {
    public let view: UIView
    public init(_ view: UIView) {
        self.view = view
    }
}

extension UIView {
    public var badge: Badge {
        get { return Badge(self) }
    }
}

extension Badge {
    
    public var isHidden: Bool {
        get {
            return self.view.isBadgeHidden
        }
        set {
            newValue ? self.view.showBadge() : self.view.hidenBadge()
        }
    }
    
    public var count: Int? {
        get {
            return Int(self.view.badgeView?.text ?? "")
        }
        set {
            guard let newValue = newValue, newValue > 0 else {
                self.view.hidenBadge()
                return
            }
            self.view.showBadge(count: newValue)
        }
    }
    
}


extension UIView {
    
    func showBadge() {
        guard self.badgeView == nil else {
            return
        }
        
        let frame = CGRect(x: self.frame.width - rightRange - 2*pointWidth, y: upRange, width: pointWidth, height: pointWidth)
        self.badgeView = UILabel(frame: frame)
        self.badgeView?.backgroundColor = UIColor.red
        self.badgeView?.layer.cornerRadius = pointWidth / 2
        self.badgeView?.layer.masksToBounds = true
        self.addSubview(self.badgeView!)
        self.bringSubview(toFront: self.badgeView!)
    }
    
    func showBadge(count: Int) {
        if count < 0 {
            return
        }
        
        self.showBadge()
        self.badgeView?.textColor = UIColor.white
        self.badgeView?.font = UIFont.systemFont(ofSize: badgeFont)
        self.badgeView?.textAlignment = .center
        self.badgeView?.text = count > 99 ? "99+" : "\(count)"
        self.badgeView?.sizeToFit()
        var frame = self.badgeView!.frame
        frame.size.width += 4
        frame.size.height += 4
        if frame.width < frame.height {
            frame.size.width = frame.height
        }
        self.badgeView?.frame = frame
        self.badgeView?.layer.cornerRadius = frame.height / 2
    }
    
    func hidenBadge() {
        self.badgeView?.removeFromSuperview()
        self.badgeView = nil
    }
    
    var isBadgeHidden: Bool {
        return self.badgeView == nil
    }
    
    var badgeView: UILabel? {
        get {
            return objc_getAssociatedObject(self, &badgeViewKey) as? UILabel
        }
        set {
            objc_setAssociatedObject(self, &badgeViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

fileprivate var badgeViewKey: Void?
fileprivate let pointWidth: CGFloat = 6 //小红点的宽高
fileprivate let rightRange: CGFloat = 8.0 //距离控件右边的距离
fileprivate let upRange: CGFloat = 2.0
fileprivate let badgeFont: CGFloat = 9 //字体的大小
