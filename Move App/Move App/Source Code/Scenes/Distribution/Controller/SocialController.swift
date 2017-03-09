//
//  SocialController.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class SocialController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    @IBAction func alertBtnDidTap(_ sender: UIButton) {
        
//        if let alerVC = R.storyboard.social.alert() {
//            alerVC.alertTitle = "Warming"
//            alerVC.content = "Mother's phone number has been changed"
//            alerVC.iconURL = "http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg"
//            alerVC.cancelAction = AlertController.Action(title: "确定", handler: {
//                Logger.debug("Alert VC cancel ation!")
//            })
//            alerVC.confirmAction = AlertController.Action(title: "执行", handler: {
//                Logger.debug("Alert VC confirm action!")
//            })
//            self.present(alerVC, animated: true)
//        }
        
        AlertWireframe.presentAlert("Mother's phone number has been changed")
        
    }

}
