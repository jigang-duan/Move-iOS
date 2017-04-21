//
//  CantPairViewController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CantPairViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    
    @IBAction func yesClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
 
    
}
