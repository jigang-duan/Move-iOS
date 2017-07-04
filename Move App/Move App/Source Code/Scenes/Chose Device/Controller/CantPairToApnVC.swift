//
//  CantPairToApnVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CantPairToApnVC: UIViewController {
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var apnBun: UIButton!
    
    var imei = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func initializeI18N() {
        titleLab.text = R.string.localizable.id_cant_pair()
        tipLab.text = R.string.localizable.id_help_apn()
        
        apnBun.setTitle(R.string.localizable.id_apn_setting(), for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.cantPairToApnVC.showApn(segue: segue)?.destination {
            vc.hasPairedWatch = false
            vc.imei = imei
        }
    }
    
  
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

