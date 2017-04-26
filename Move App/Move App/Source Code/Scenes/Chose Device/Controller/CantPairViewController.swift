//
//  CantPairViewController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CantPairViewController: UIViewController {
    
    
    var imei = ""
    var showTipBlock: (() -> ())?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    @IBAction func yesClick(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
        if self.showTipBlock != nil {
            self.showTipBlock!()
        }
    }
 
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.cantPairViewController.showApnSetting(segue: segue)?.destination {
            vc.imei = imei
        }
    }
    
    
    
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
