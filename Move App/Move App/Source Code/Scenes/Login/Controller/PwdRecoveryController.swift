//
//  PwdRecoveryController.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class PwdRecoveryController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func BackAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func DoneAction(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UpdataPwdController") as! UpdataPwdController
        
    
        
        self.present(vc, animated: true
        ) {
            
               vc.remindLabel.text = "Help us protect your.The verification code was sent to your Email "+self.EmailTextField.text!+"."
                
        }
        
        
        
    }
    
    

}
