//
//  SignUpViewController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        
    }

   
    
    @IBOutlet weak var emailTextfield: UITextField!
    //返回上一级页面
    @IBAction func BackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
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
