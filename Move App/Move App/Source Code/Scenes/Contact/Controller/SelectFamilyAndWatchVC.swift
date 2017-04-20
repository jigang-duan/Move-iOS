//
//  SelectFamilyAndWatchVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class SelectFamilyAndWatchVC: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.selectFamilyAndWatchVC.showFamilyMember(segue: segue)?.destination {
            vc.isMater = true
        }
    }
    
    
    
}
