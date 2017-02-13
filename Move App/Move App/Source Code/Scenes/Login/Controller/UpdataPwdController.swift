//
//  UpdataPwdController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class UpdataPwdController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var remindLabel: UILabel!

   
}
extension UpdataPwdController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
