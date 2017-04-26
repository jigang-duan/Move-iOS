//
//  RemindersCell.swift
//  Move App
//
//  Created by LX on 2017/3/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CustomViews



class RemindersCell: UITableViewCell {
    @IBOutlet weak var titleimage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailtitleLabel: UILabel!
    @IBOutlet weak var accviewBtn: SwitchButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
    }
    
}
