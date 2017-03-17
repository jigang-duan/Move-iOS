//
//  FamilyMemberTableViewCell.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class FamilyMemberTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var heartBun: UIButton!
    @IBOutlet weak var headImgV: UIImageView!
    @IBOutlet weak var relationName: UILabel!
    @IBOutlet weak var detailLab: UILabel!
    
    var heartClick: ((Void) -> Void)?
    var isHeartOn: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    
    
    @IBAction func heartClick(_ sender: Any) {
        if self.heartClick != nil {
            self.heartClick!()
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
