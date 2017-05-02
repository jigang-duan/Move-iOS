//
//  FamilyMemberCell.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class FamilyMemberCell: UICollectionViewCell {
    
    var imageView: UIImageView {
        return (viewWithTag(1) as? UIImageView)!
    }

    var textLabel: UILabel {
         return (viewWithTag(2) as? UILabel)!
    }
    
}
