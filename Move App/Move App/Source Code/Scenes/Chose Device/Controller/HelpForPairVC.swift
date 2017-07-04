//
//  HelpForPairVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/7/4.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class HelpForPairVC: UIViewController {

    
    private func initializeI18N() {
        self.title = R.string.localizable.id_help_for_paired()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeI18N()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
