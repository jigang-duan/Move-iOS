//
//  LoginViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    let error = true
    @IBOutlet weak var errorTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailLineView: UIView!
    
    @IBOutlet weak var AccounterrorLabel: UILabel!
    
    @IBAction func LoginClick(_ sender: AnyObject) {
        //当帐号不存在de时候
        if error {
            errorTopConstraint.constant = 30
            emailLineView.backgroundColor = UIColor.red
            AccounterrorLabel.isHidden = false
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
}
