//
//  PulsingAnnotationView.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/5.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import MapKit

public class PulsingAnnotationView: MKAnnotationView {
    
    public var annotationColor: UIColor = UIColor(red: 0, green: 0.478, blue: 1.00, alpha: 1.0) {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    public var dotColorDot: UIColor = UIColor(red: 0.992156863212585, green: 0.737254917621613, blue: 0.0, alpha: 1.0) {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    public var pulseAnimationDuration: TimeInterval = 1.0 {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    public var outerPulseAnimationDuration: TimeInterval = 3.0 {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    public var delayBetweenPulseCycles: TimeInterval = 3.0 {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    public var radius: CGFloat = 120.0 {
        didSet {
            if self.superview != nil {
                self.rebuildLayers()
            }
        }
    }
    
    private var _whiteDotLayer: CALayer?
    private var _colorDotLayer: CALayer?
    private var _colorHaloLayer: CALayer?
    
    override public init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.calloutOffset = CGPoint(x: 0, y: 4)
        
        self.bounds = CGRect(x: 0, y: 0, width: 22, height: 22)
        self.pulseAnimationDuration = 1.5
        self.outerPulseAnimationDuration = 3
        self.delayBetweenPulseCycles = 0
    }
    
    private func rebuildLayers() {
        whiteDotLayer?.removeFromSuperlayer()
        whiteDotLayer = nil
        colorDotLayer?.removeFromSuperlayer()
        colorDotLayer = nil
        colorHaloLayer?.removeFromSuperlayer()
        colorHaloLayer = nil
        
        self.layer.addSublayer(self.colorHaloLayer!)
        self.layer.addSublayer(self.whiteDotLayer!)
        self.layer.addSublayer(self.colorDotLayer!)
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            rebuildLayers()
            popIn()
        }
    }
    
    private func popIn() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        let easeInOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        bounceAnimation.values = [0.05, 1.25, 0.8, 1.1, 0.9, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.timingFunctions = [easeInOut, easeInOut, easeInOut, easeInOut, easeInOut, easeInOut]
        self.layer.add(bounceAnimation, forKey: "popIn")
    }
    
    var whiteDotLayer: CALayer? {
        get {
            if _whiteDotLayer == nil {
                _whiteDotLayer = CALayer()
                _whiteDotLayer?.bounds = self.bounds
                _whiteDotLayer?.contents = self.circleImage(color: UIColor.white, height: 22).cgImage
                _whiteDotLayer?.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
                _whiteDotLayer?.contentsGravity = kCAGravityCenter
                _whiteDotLayer?.contentsScale = UIScreen.main.scale
                _whiteDotLayer?.shadowColor = UIColor.black.cgColor
                _whiteDotLayer?.shadowRadius = 3
                _whiteDotLayer?.shadowOpacity = 0.3
                _whiteDotLayer?.shouldRasterize = true
                _whiteDotLayer?.rasterizationScale = UIScreen.main.scale
            }
            return _whiteDotLayer
        }
        set {
            _whiteDotLayer = newValue
        }
    }
    
    var colorDotLayer: CALayer? {
        get {
            if _colorDotLayer == nil {
                _colorDotLayer = CALayer()
                _colorDotLayer?.bounds = CGRect(x: 0, y: 0, width: 16, height: 16)
                _colorDotLayer?.allowsGroupOpacity = true
                _colorDotLayer?.backgroundColor = self.dotColorDot.cgColor
                _colorDotLayer?.cornerRadius = 8
                _colorDotLayer?.position = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
                
                DispatchQueue.global(qos: .default).async {
                    if self.delayBetweenPulseCycles != TimeInterval.infinity {
                        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
                        
                        let animationGroup = CAAnimationGroup()
                        animationGroup.duration = self.pulseAnimationDuration
                        animationGroup.repeatCount = Float.infinity
                        animationGroup.isRemovedOnCompletion = false
                        animationGroup.autoreverses = true
                        animationGroup.beginTime = 1.0
                        animationGroup.timingFunction = defaultCurve
                        animationGroup.speed = 1
                        animationGroup.fillMode = kCAFillModeBoth
                        
                        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
                        pulseAnimation.fromValue = 0.7
                        pulseAnimation.toValue = 1
                        pulseAnimation.duration = self.pulseAnimationDuration
                        
                        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                        opacityAnimation.fromValue = 0.6
                        opacityAnimation.toValue = 1.0
                        opacityAnimation.duration = self.pulseAnimationDuration
                        
                        animationGroup.animations = [pulseAnimation, opacityAnimation]
                        
                        DispatchQueue.main.async {
                            self._colorDotLayer?.add(animationGroup, forKey: "pulse")
                        }
                    }
                }
            }
            return _colorDotLayer
        }
        set {
            _colorDotLayer = newValue
        }
    }
    
    var colorHaloLayer: CALayer? {
        get {
            if _colorHaloLayer == nil {
                _colorHaloLayer = CALayer()
                _colorHaloLayer?.bounds = CGRect(origin: CGPoint.zero,
                                                 size: CGSize(width: self.radius*2, height: self.radius*2))
                _colorHaloLayer?.position = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
                _colorHaloLayer?.contentsScale = UIScreen.main.scale
                _colorHaloLayer?.backgroundColor = self.annotationColor.cgColor
                _colorHaloLayer?.cornerRadius = self.radius
                _colorHaloLayer?.opacity = 0
                
                DispatchQueue.global(qos: .default).async {
                    if
                        self.radius > self.bounds.width,
                        self.delayBetweenPulseCycles != TimeInterval.infinity {
                        let animationGroup = self.pulseAnimationGroup()
                        
                        DispatchQueue.main.async {
                            self._colorHaloLayer?.add(animationGroup, forKey: "pulse")
                        }
                    }
                }
            }
            return _colorHaloLayer
        }
        set {
            _colorHaloLayer = newValue
        }
    }
    
    private func pulseAnimationGroup() -> CAAnimationGroup {
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let $ = CAAnimationGroup()
        $.duration = self.outerPulseAnimationDuration + self.delayBetweenPulseCycles
        $.repeatCount = Float.infinity
        $.isRemovedOnCompletion = false
        $.timingFunction = defaultCurve
        
        var animations: [CAAnimation] = []
        
        //        let imageAnimation = CAKeyframeAnimation(keyPath: "contents")
        //        imageAnimation.duration = self.pulseAnimationDuration
        //        imageAnimation.calculationMode = kCAAnimationDiscrete
        //        imageAnimation.values = [
        //            self.haloImage(radius: 20).cgImage!,
        //            self.haloImage(radius: 35).cgImage!,
        //            self.haloImage(radius: 50).cgImage!
        //        ]
        //        animations.append(imageAnimation)
        
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        pulseAnimation.fromValue = 0.0
        pulseAnimation.toValue = 1.0
        animations.append(pulseAnimation)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = self.outerPulseAnimationDuration
        opacityAnimation.timingFunction = defaultCurve
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = kCAFillModeForwards
        animations.append(opacityAnimation)
        
        $.animations = animations
        
        return $
    }
    
    private func haloImage(radius: CGFloat) -> UIImage {
        let key = String(format: "%@-%.0f", self.annotationColor, radius)
        var rinagImage = PulsingAnnotationView.cachedRingImages[key]
        
        if rinagImage == nil {
            let glowRadius = radius / 6;
            let ringThickness = radius / 24;
            let center = CGPoint(x: glowRadius + radius, y: glowRadius + radius)
            let imageBounds = CGRect(x: 0, y: 0, width: center.x*2, height: center.y*2)
            let ringFrame = CGRect(x: glowRadius, y: glowRadius, width: radius*2, height: radius*2)
            
            UIGraphicsBeginImageContextWithOptions(imageBounds.size, false, 0)
            let contex = UIGraphicsGetCurrentContext()
            let ringColor = UIColor.white
            ringColor.setFill()
            
            let ringPath = UIBezierPath(ovalIn: ringFrame)
            ringPath.append(UIBezierPath(ovalIn: ringFrame.insetBy(dx: ringThickness, dy: ringThickness)))
            ringPath.usesEvenOddFillRule = true
            
            for i in sequence(first: CGFloat(1.3), next: { $0 - 0.18 }).prefix(5) {
                let blurRadius = [1.0, i].min()!*glowRadius
                contex?.setShadow(offset: CGSize.zero, blur: blurRadius, color: self.annotationColor.cgColor)
                ringPath.fill()
            }
            
            rinagImage = UIGraphicsGetImageFromCurrentImageContext()
            PulsingAnnotationView.cachedRingImages[key] = rinagImage!
            
            UIGraphicsEndImageContext()
        }
        
        return rinagImage!
    }
    
    static var cachedRingImages: [String: UIImage] = [:]
    
    private func circleImage(color: UIColor, height: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: height, height: height), false, 0)
        _ = CGColorSpaceCreateDeviceRGB()
        let fillPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: height, height: height))
        color.setFill()
        fillPath.fill()
        
        let dotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return dotImage!
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
