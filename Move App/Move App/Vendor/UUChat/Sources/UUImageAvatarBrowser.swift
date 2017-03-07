//
//  UUImageAvatarBrowser.swift
//  UUChat
//
//  Created by jiang.duan on 2017/3/2.
//  Copyright © 2017年 jiang.duan. All rights reserved.
//

import UIKit

class UUImageAvatarBrowser  {
    
    private var orginImageView: UIImageView?
    
    func showImage(avatarImageView: UIImageView) {
        
        guard let image = avatarImageView.image else {
            return
        }
        orginImageView = avatarImageView
        orginImageView?.alpha = 0
        
        let window = UIApplication.shared.keyWindow
        let screenSize = UIScreen.main.bounds.size
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        let oldframe = avatarImageView.convert(avatarImageView.bounds, to: window)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.alpha = 0.0
        let imageView = UIImageView(frame: oldframe)
        imageView.image = image
        imageView.tag = 1
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        backgroundView.addSubview(imageView)
        window?.addSubview(backgroundView)
        
        backgroundView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideImage(_:)))
        backgroundView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.4, animations: {
            imageView.frame = CGRect(x: 0,
                                     y: (screenSize.height - image.size.height*screenSize.width/image.size.width) / 2,
                                     width: screenSize.width,
                                     height: image.size.height*screenSize.width/image.size.width)
            backgroundView.alpha = 1.0
        }, completion: nil)
    }
    
    @objc func hideImage(_ tap: UIGestureRecognizer) {
        let backgroundView = tap.view
        let imageView = backgroundView?.viewWithTag(1) as? UIImageView
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            if let orginImageView = self?.orginImageView {
                imageView?.frame = orginImageView.convert(orginImageView.bounds, to: UIApplication.shared.keyWindow)
            }
            self?.orginImageView?.alpha = 1.0
            backgroundView?.alpha = 0.0
        }, completion: { _ in
            backgroundView?.removeFromSuperview()
        })
    }
    
}
