//
//  APNSettingVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class APNSettingVC: UITableViewController {
    
    var settingDataBlock: ((Data?) -> Void)?
    
    @IBOutlet weak var plmnTf: UITextField!
    @IBOutlet weak var apnTf: UITextField!
    @IBOutlet weak var spnTf: UITextField!
    
    @IBOutlet weak var userTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var proxyAddTf: UITextField!
    @IBOutlet weak var proxyPortTf: UITextField!
    
    @IBOutlet weak var authSegment: UISegmentedControl!
 
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let str = APNforWatchVC.APNData(plmn: "1", apn: "2", spn: "3", user: "4", password: "5", proxy: "6", port: "7", authtype: "8").toJSONString()
        let data = str?.data(using: String.Encoding.utf8)
        
        if self.settingDataBlock != nil {
            self.settingDataBlock!(data)
        }
        
        
    }
    
    
    
    
    
    
    
}





