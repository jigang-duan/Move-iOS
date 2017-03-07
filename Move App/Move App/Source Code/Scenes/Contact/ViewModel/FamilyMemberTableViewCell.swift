//
//  FamilyMemberTableViewCell.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class FamilyMemberTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var heartImgV: UIImageView!
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var relationName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
