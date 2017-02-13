//
//  SignUpViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    
        
    }

   
    
    @IBOutlet weak var emailTextfield: UITextField!
    //返回上一级页面
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    //使用条款
    @IBAction func UseTermsAction(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func SignAction(_ sender: AnyObject) {
        
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProtectAccountController") as! ProtectAccountController
        self.present(vc, animated: true) {
            vc.remendLabel.text = "Help us protect your.The verification code was sent to your Email "+self.emailTextfield.text!+"."
        }
    }
    
}

extension SignUpViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
