//
//  RulerScrollView.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class RulerScroll: UIScrollView {
    
    var maxValue: UInt?
    
    let lineHeight: CGFloat = 20
    
    func drawRuler() {
        
        let path = CGMutablePath()
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        layer.lineCap = kCALineCapButt
        
        
        for i:UInt in 0...(maxValue ?? 0) {
            
            if i%10 == 0 {
                let lab = UILabel(frame: CGRect(x: self.frame.size.width/2 + CGFloat(i*interval) - 40, y: lineHeight*3 + 10, width: 80, height: 20))
                lab.font = UIFont.systemFont(ofSize: 14)
                lab.textAlignment = .center
                lab.textColor = UIColor.lightGray
                lab.text = "\(i)"
                self.addSubview(lab)
                
                path.move(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: 0))
                path.addLine(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: lineHeight*3))
            }else if i%5 == 0 {
                path.move(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: lineHeight*0.5))
                path.addLine(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: lineHeight*2.5))
            }else{
                path.move(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: lineHeight))
                path.addLine(to: CGPoint(x: self.frame.size.width/2 + CGFloat(i*interval), y: lineHeight*2))
            }
            
        }
        
        layer.path = path
        
        self.layer.addSublayer(layer)
    
    }
    
    
    
}

