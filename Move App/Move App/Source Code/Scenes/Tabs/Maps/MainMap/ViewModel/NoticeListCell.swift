//
//  NoticeListCell.swift
//  Move App
//
//  Created by lx on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class NoticeListCell: UITableViewCell {
    @IBOutlet weak var avartarImg: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var addressL: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}