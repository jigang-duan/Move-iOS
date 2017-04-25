//
//  ContactAnnotationView.swift
//  Move App
//
//  Created by lx on 17/3/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews

class ContactAnnotationView: MKAnnotationView {
    
    var subview : contactCell!
    var avatarImage : UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        subview = Bundle.main.loadNibNamed("contactCell", owner: self, options: nil)?.first as! contactCell
        subview.isUserInteractionEnabled = false
        self.addSubview(subview)
        avatarImage = UIImageView.init(frame: CGRect(x : 13,y : 7, width : 54,height : 54  ))
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 27
        self.addSubview(avatarImage)
        self.frame.size = CGSize(width : 80 ,height : 80)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvatarImage(nikename : String , profile : String) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 54, height: 54), fullName: nikename ).imageRepresentation()!
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 27
        let imgUrl = URL(string: FSManager.imageUrl(with: profile))
        avatarImage.kf.setImage(with: imgUrl, placeholder: placeImg)
    }
}

class BigContactAnnotationView: MKAnnotationView {
    
    var subview : contactCell!
    var avatarImage : UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        subview = Bundle.main.loadNibNamed("contactCell", owner: self, options: nil)?.first as! contactCell
        subview.isUserInteractionEnabled = false
        self.addSubview(subview)
        subview.frame = CGRect(x : 13,y : 7, width : 120,height : 120  )
        avatarImage = UIImageView.init(frame: CGRect(x : 13,y : 7, width : 94,height : 94  ))
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 47
        self.addSubview(avatarImage)
        self.frame.size = CGSize(width : 120 ,height : 120)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvatarImage(nikename : String , profile : String) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 54, height: 54), fullName: nikename ).imageRepresentation()!
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 27
        let imgUrl = URL(string: FSManager.imageUrl(with: profile))
        avatarImage.kf.setImage(with: imgUrl, placeholder: placeImg)
    }
    
}

