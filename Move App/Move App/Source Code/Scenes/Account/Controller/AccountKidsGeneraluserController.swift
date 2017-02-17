//
//  AccountKidsGeneraluserController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class AccountKidsGeneraluserController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

 
    }
    
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0
        {
            return "Function"
        }else
        {
            return "Settings"
        }
        
    }
   

}
