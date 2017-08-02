//
//  schoolTimeHelp.swift
//  Move App
//
//  Created by LX on 2017/4/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class schoolTimeHelp: UIView {
    
  
    @IBOutlet weak var helpLab: UILabel!

    @IBAction func removeView(_ sender: Any) {
        removeFromSuperview()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        helpLab.text = R.string.localizable.id_school_time_on()
    }
    
}
