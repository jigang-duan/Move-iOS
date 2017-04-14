//
//  ContactUsTableVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit


class ContactUsTableVC: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            let url = URL(string: "http://www.tcl.com")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    
    
}
