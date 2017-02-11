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

   
    
    //返回上一级页面
    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    //使用条款
    @IBAction func UseTermsAction(_ sender: AnyObject) {
        
        
    }
    
    
}

extension SignUpViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
