//
//  CantPairViewController.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/4/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class CantPairViewController: UIViewController {
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var tipLab: UILabel!
    
    @IBOutlet weak var yesBun: UIButton!
    @IBOutlet weak var noBun: UIButton!
    
    
    var imei = ""
    var showTipBlock: (() -> ())?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func initializeI18N() {
        titleLab.text = R.string.localizable.id_cant_pair()
        tipLab.text = R.string.localizable.id_help_apn_week()
        
        yesBun.setTitle(R.string.localizable.id_yes(), for: .normal)
        noBun.setTitle(R.string.localizable.id_no(), for: .normal)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
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
