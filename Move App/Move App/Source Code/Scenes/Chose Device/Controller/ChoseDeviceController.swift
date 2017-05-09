//
//  ChoseDeviceController.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ChoseDeviceController: UITableViewController {

    @IBOutlet weak var skipBarBtnItem: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navItem.title = R.string.localizable.id_choose_device()
        skipBarBtnItem.title = R.string.localizable.id_skip()
        
    }

    
}
