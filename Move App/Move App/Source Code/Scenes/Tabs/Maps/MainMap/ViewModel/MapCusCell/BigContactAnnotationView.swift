//
//  BigContactAnnotationView.swift
//  Move App
//
//  Created by lx on 17/4/26.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews

class HeadPortraitAnnotationView: MKAnnotationView {
    
    var type: Type = .medium {
        didSet {
            switch type {
            case .big:
                backgroundView.frame = Big_Background_Rect
                headPortraitView.frame = Big_HeadPortrait_Rect
                headPortraitView.layer.masksToBounds = true
                headPortraitView.layer.cornerRadius = Big_HeadPortrait_Rect.width / 2
                self.frame.size = Big_Background_Rect.size
            case .medium:
                backgroundView.frame = Medium_Background_Rect
                headPortraitView.frame = Medium_HeadPortrait_Rect
                headPortraitView.layer.masksToBounds = true
                headPortraitView.layer.cornerRadius = Medium_HeadPortrait_Rect.width / 2
                self.frame.size = Medium_Background_Rect.size
            }
        }
    }
    
    func setHeadPortrait(name: String, url: String) {
        let placeImg = CDFInitialsAvatar(rect: headPortraitView.bounds, fullName: name).imageRepresentation()!
        let imageURL = URL(string: FSManager.imageUrl(with: url))
        headPortraitView.kf.setImage(with: imageURL, placeholder: placeImg)
    }
    
    lazy var headPortraitView: UIImageView = {
        let $ = UIImageView()
        $.contentMode = .scaleToFill
        $.isUserInteractionEnabled = false
        $.image = R.image.member_btn_contact_nor()
        return $
    }()
    
    lazy var backgroundView: UIImageView = {
        let $ = UIImageView()
        $.isUserInteractionEnabled = false
        $.contentMode = .scaleToFill
        $.image = R.image.all_loaction_nor()
        return $
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.addSubview(backgroundView)
        self.addSubview(headPortraitView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum `Type` {
        case big
        case medium
    }
    
    let Medium_Background_Rect = CGRect(x: 0, y: 0, width: 60, height: 60)
    let Medium_HeadPortrait_Rect = CGRect(x: 9.75, y: 5.25, width: 40.5, height: 40.5)
    let Big_Background_Rect   = CGRect(x: 0, y: 0, width: 90, height: 90)
    let Big_HeadPortrait_Rect = CGRect(x: 15, y: 7.78, width: 60, height: 60)
}
