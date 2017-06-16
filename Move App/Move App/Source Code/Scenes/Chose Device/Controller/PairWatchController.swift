//
//  PairWatchController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class PairWatchController: UIViewController {

    @IBOutlet weak var tipBottomCons: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let screenH = UIScreen.main.bounds.height
        if screenH < 500 {
            tipBottomCons.constant = 10
        }else if screenH > 500 && screenH < 600 {
            tipBottomCons.constant = 20
        }else{
            tipBottomCons.constant = 43
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

