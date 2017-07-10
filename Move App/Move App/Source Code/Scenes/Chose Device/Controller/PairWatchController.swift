//
//  PairWatchController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class PairWatchController: UIViewController {

    @IBOutlet weak var scanBun: UIButton!
    @IBOutlet weak var tipBun: UIButton!
    
    
    @IBOutlet weak var tipBottomCons: NSLayoutConstraint!
    
    private func initializeI18N() {
        scanBun.setTitle(R.string.localizable.id_scan_qr_code(), for: .normal)
        tipBun.setTitle(R.string.localizable.id_where_is_qr_cord(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()

        // Do any additional setup after loading the view.
        
        let screenH = UIScreen.main.bounds.height
        if screenH < 500 {
            tipBottomCons.constant = 10
        }else if screenH > 500 && screenH < 600 {
            tipBottomCons.constant = 20
        }else{
            tipBottomCons.constant = 30
        }
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
}

