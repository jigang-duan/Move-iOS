//
//  ProgressHUD.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/5/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit



public class ProgressHUD: UIView{

    private var textLab: UILabel?
    
    private static let shareView = ProgressHUD()
    private static var once = 0
    
    private class func shared() -> ProgressHUD {
        if once == 0 {
            once = 1
            
            shareView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 44)
            shareView.layer.cornerRadius = 5
            shareView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            
            shareView.textLab = UILabel(frame: CGRect(x: 0, y: 0, width: shareView.frame.size.width, height: shareView.frame.size.height))
            shareView.textLab?.textColor = UIColor.white
            shareView.textLab?.numberOfLines = 0
            shareView.textLab?.textAlignment = .center
            shareView.textLab?.font = UIFont.systemFont(ofSize: 14)
            shareView.addSubview(shareView.textLab!)
        }
        
        return shareView
    }
    
    
    public class func show(status: String, progress: Float = 3) {
        self.dismiss()
        
        DispatchQueue.main.async {
            let hud = ProgressHUD.shared()
            
            
            self.frontWindow()?.addSubview(hud)
            
            let str = NSString(string: status)
            let height = str.boundingRect(with: CGSize(width: (hud.textLab?.frame.size.width)!, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil).size.height
            
            let hudFrame = hud.frame
            hud.frame.size.height = height
            hud.frame = hudFrame
            hud.center = (self.frontWindow()?.center)!
            
            let labFrame =  hud.textLab?.frame
            hud.textLab?.frame.size.height = height
            hud.textLab?.frame = labFrame!
            hud.textLab?.text = str as String
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(progress * 1000))){
                self.dismiss()
            }
        }
    
    }
  
    
    public class func dismiss() {
        DispatchQueue.main.async {
            if let _ = ProgressHUD.shared().superview {
                ProgressHUD.shared().removeFromSuperview()
            }
        }
    }
    
    
    
    private class func frontWindow() -> UIWindow? {
        
        let frontToBackWindows = UIApplication.shared.windows.reversed()
        
        for wd in frontToBackWindows {
            let windowOnMainScreen = wd.screen == UIScreen.main
            let windowIsVisible = !wd.isHidden && wd.alpha > 0
            let windowLevelSupported = wd.windowLevel >= UIWindowLevelNormal
            let windowKeyWindow = wd.isKeyWindow
        
            if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
                return wd
            }
        }
    
        return nil
    }
    
    
    
}
