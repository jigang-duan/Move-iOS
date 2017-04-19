//
//  AboutViewController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit



class AboutViewController: UIViewController {
    
    
    @IBOutlet weak var versionLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            versionLab.text = "V \(version)"
        }
        
    }
    
    
    
    
    
    
}
