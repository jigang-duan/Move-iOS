//
//  NoEventView.swift
//  Move App
//
//  Created by lx on 17/2/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

@IBDesignable
public class NoEventView: UIView {
    
    @IBInspectable
    public var radius: CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var strokeColor: UIColor = UIColor(red:0.0, green:0.62, blue:1.0, alpha:1.0)
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.superview
    }
    
    override public func draw(_ rect: CGRect) {
        //super.draw(rect)
        
        // Get the Graphics Context
        let context = UIGraphicsGetCurrentContext()
        
        // Set the circle outerline-width
        context?.setLineWidth(1.0)
        context?.setLineDash(phase: 0, lengths: [6, 6])
        
        // Set the circle outerline-colour
        strokeColor.withAlphaComponent(0.7).setStroke()
        strokeColor.withAlphaComponent(0.1).setFill()
        
        // Create Circle
        context?.addArc(center: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2),
                        radius:  self.radius,
                        startAngle:  0.0,
                        endAngle: CGFloat.pi * 2.0,
                        clockwise: true)
        // Draw
        context?.drawPath(using: .fillStroke)
    }
    
}
