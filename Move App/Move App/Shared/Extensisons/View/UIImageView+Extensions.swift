//
//  UIImageView+Extensions.swift
//  RxExample
//
//  Created by carlos on 28/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CustomViews

extension UIImageView {
    
    func makeRoundedCorners(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }

    func makeRoundedCorners() {
        self.makeRoundedCorners(self.frame.size.width / 2)
    }
}

extension Reactive where Base: UIImageView {
}

extension UIImage {
    
    func grayImage() -> UIImage {
        let imageRef = self.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(imageRef, in: rect)
        let outPutImage = context.makeImage()!
        let newImage = UIImage(cgImage: outPutImage, scale: self.scale, orientation: self.imageOrientation)
        return newImage
    }
    
    func resizingStretchImage() -> UIImage {
        return self.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }
}

extension Reactive where Base: ActivityImageView {
    
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { activityIndicator, active in
            if active {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
}
