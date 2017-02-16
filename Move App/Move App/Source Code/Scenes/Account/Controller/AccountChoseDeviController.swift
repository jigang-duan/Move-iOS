//
//  AccountChoseDeviController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/16.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class AccountChoseDeviController: UITableViewController {

    @IBOutlet weak var UsersView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavView()
        
    }
    
    private func setNavView() {
        UsersView.backgroundColor = ThemeManager.currentTheme().mainColor
        self.navigationController?.navigationBar.clipsToBounds = true
    }
   
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Device"
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
}
