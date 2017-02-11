//
//  ProtectAccountController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class ProtectAccountController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBOutlet weak var HelpLabel: UILabel!
    
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}

extension ProtectAccountController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
