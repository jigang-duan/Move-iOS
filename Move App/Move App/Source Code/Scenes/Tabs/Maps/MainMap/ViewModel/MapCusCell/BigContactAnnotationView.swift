//
//  BigContactAnnotationView.swift
//  Move App
//
//  Created by lx on 17/4/26.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews

class BigContactAnnotationView: MKAnnotationView {
    
    var subview : BigContactcell!
    var avatarImage : UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        subview = Bundle.main.loadNibNamed("BigContactcell", owner: self, options: nil)?.first as! BigContactcell
        subview.isUserInteractionEnabled = false
        self.addSubview(subview)
        subview.frame = CGRect(x : 0,y : -15, width : 120,height : 120  )
        avatarImage = UIImageView.init(frame: CGRect(x : 20,y : -3, width : 80,height : 80  ))
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 45
        self.addSubview(avatarImage)
        self.frame.size = CGSize(width : 120 ,height : 120)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvatarImage(nikename : String , profile : String) {
        let placeImg = CDFInitialsAvatar(rect: CGRect(x: 0, y: 0, width: 80, height: 80), fullName: nikename ).imageRepresentation()!
        avatarImage.layer.masksToBounds = true
        avatarImage.layer.cornerRadius = 45
        let imgUrl = URL(string: FSManager.imageUrl(with: profile))
        avatarImage.kf.setImage(with: imgUrl, placeholder: placeImg)
    }
}
