//
//  SafezoneCell.swift
//  Move App
//
//  Created by LX on 2017/3/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews

class SafezoneCell: UITableViewCell {
    @IBOutlet weak var switchOnOffQutiet: SwitchButton!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
