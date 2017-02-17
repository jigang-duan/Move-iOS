//
//  SafeZoneTabViewCell.swift
//  Move App
//
//  Created by lx on 17/2/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SafeZoneTabViewCell: UITableViewCell {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var openSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func switchPanAction(_ sender: UISwitch) {
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
