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
    
    @IBOutlet weak var step1Lab: UILabel!
    @IBOutlet weak var step2Lab: UILabel!
    
    @IBOutlet weak var step1TextLab: UILabel!
    @IBOutlet weak var step2TextLab: UILabel!

    
    private func initializeI18N() {
        self.title = R.string.localizable.id_help_for_apn()
        
        step1Lab.text = R.string.localizable.id_step() + " 1"
        step2Lab.text = R.string.localizable.id_step() + " 2"
        
        step1TextLab.text = R.string.localizable.id_info_apn_not_paired_1()
        step2TextLab.text = R.string.localizable.id_info_apn_not_paired_3()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        tipLab.text = R.string.localizable.id_apn_unpaired_hint()
        
        
    }
    
    
    
    
    
    
}
