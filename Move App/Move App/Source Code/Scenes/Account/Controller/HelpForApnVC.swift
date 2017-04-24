//
//  HelpForApnVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit



class HelpForApnVC: UIViewController {
    
    
    @IBOutlet weak var tipLab: UILabel!
    
    @IBOutlet weak var step3View: UIView!
    @IBOutlet weak var step3HCons: NSLayoutConstraint!
    
    @IBOutlet weak var step4View: UIView!
    @IBOutlet weak var step4HCons: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var step2LeftLab: UILabel!
    
    @IBOutlet weak var step2SwipImgV: UIImageView!
    
    @IBOutlet weak var step2TextLab: UILabel!
    @IBOutlet weak var step2ImgV: UIImageView!
    @IBOutlet weak var lastStepLab: UILabel!
    
    
    
    var isPaired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if isPaired == true {
            tipLab.text = "If your watch has been paired"
        }else{
            tipLab.text = "If your watch has not be paired"
            
            
            step3View.isHidden = true
            step3HCons.constant = 0
            
            step4View.isHidden = true
            step4HCons.constant = 0
            
            step2TextLab.text = "Swipe right,you will see APN setting on screen"
            step2LeftLab.textColor = UIColor.lightGray
            step2SwipImgV.image = R.image.swipe_right()
            step2ImgV.image = R.image.help_5()
            
            
            lastStepLab.text = "Step 3"
            
        }
        
        
    }
    
    
    
    
    
    
}
