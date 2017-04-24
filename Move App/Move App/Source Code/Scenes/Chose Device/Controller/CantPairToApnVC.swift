//
//  CantPairToApnVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CantPairToApnVC: UIViewController {
    
    
    var imei = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.cantPairToApnVC.showApn(segue: segue)?.destination {
            vc.hasPairedWatch = false
            vc.imei = imei
        }
    }
    
    
    
}

