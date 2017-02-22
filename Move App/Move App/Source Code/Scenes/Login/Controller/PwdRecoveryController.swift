//
//  PwdRecoveryController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class PwdRecoveryController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBOutlet weak var EmailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func BackAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
   
   
    
    

}
extension PwdRecoveryController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

