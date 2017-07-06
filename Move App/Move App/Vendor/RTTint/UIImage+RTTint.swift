//
//  UIImage+RTTint.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/6.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

public extension UIImage {
    
    func rt_tintedImage(color: UIColor) -> UIImage {
        return self.rt_tintedImage(color: color, level: 1.0)
    }
    
    func rt_tintedImage(color: UIColor, level: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        return self.rt_tintedImage(color: color, rect: rect, level: level)
    }
    
    func rt_tintedImage(color: UIColor, rect: CGRect) -> UIImage {
        return self.rt_tintedImage(color: color, rect: rect, level: 1.0)
    }

    func rt_tintedImage(color: UIColor, rect: CGRect, level: CGFloat) -> UIImage {
        let imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, self.scale)
        let ctx = UIGraphicsGetCurrentContext()!
        
        self.draw(in: imageRect)
        
        ctx.setFillColor(color.cgColor)
        ctx.setAlpha(level)
        ctx.setBlendMode(.sourceAtop)
        ctx.fill(rect)
        
        let imageRef = ctx.makeImage()!
        let darkImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsEndImageContext()
        
        return darkImage
    }

}
