//
//  APNSettingVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit

class APNSettingVC: UITableViewController {
    
    var settingDataBlock: ((Data?) -> Void)?
    
    @IBOutlet weak var plmnTf: UITextField!
    @IBOutlet weak var apnTf: UITextField!
    @IBOutlet weak var spnTf: UITextField!
    
    @IBOutlet weak var userTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var proxyAddTf: UITextField!
    @IBOutlet weak var proxyPortTf: UITextField!
    
    @IBOutlet weak var authSegment: UISegmentedControl!
 
    
    @IBOutlet weak var okBun: UIBarButtonItem!
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apnSettingNotification(_:)), name: NSNotification.Name(rawValue: APNforWatchVC.ApnDoneNotification), object: nil)
        
        
        authSegment.selectedSegmentIndex = 0
        
        activity.center = self.view.center
        self.view.addSubview(activity)
    }
    
    
    @IBAction func sendAPNSettings(_ sender: Any) {
        
        let str = APNforWatchVC.APNData(
                plmn: plmnTf.text,
                apn: apnTf.text,
                spn: spnTf.text,
                user: userTf.text,
                password: passwordTf.text,
                proxy: proxyAddTf.text,
                port: proxyPortTf.text,
                authtype: authSegment.titleForSegment(at: authSegment.selectedSegmentIndex))
            .toJSONString()
        let data = str?.data(using: String.Encoding.utf8)
        
        
        if let d = data {
            
            activity.startAnimating()
            okBun.isEnabled = false
            okBun.tintColor?.withAlphaComponent(0.5)
            
            let transData = ApnBleTool.dataTrans(with: d)
            let resultData = ApnBleTool.package(data: transData)
            
            if self.settingDataBlock != nil {
                self.settingDataBlock!(resultData)
            }
        }
    }
    
    
    func apnSettingNotification(_ notification: NSNotification) {
        if let res = notification.object as? APNforWatchVC.ApnSettingResult {
            switch res {
            case .setSuccess:
                DispatchQueue.main.async {
//                    _ = self.navigationController?.popViewController(animated: true)
                    self.showMessage("APN 设置成功")
                    self.activity.stopAnimating()
                    self.okBun.isEnabled = true
                    self.okBun.tintColor?.withAlphaComponent(1)
                }
                print("APN 设置完成")
            case .setFail:
                DispatchQueue.main.async {
                    self.showMessage("APN 设置失败")
                    self.activity.stopAnimating()
                    self.okBun.isEnabled = true
                    self.okBun.tintColor?.withAlphaComponent(1)
                }
            case .sendDone:
                print("APN 设置数据发送完成")
            case .error:
                print("APN 设置发送数据出错")
                DispatchQueue.main.async {
                    self.showMessage("APN 设置发送数据出错")
                    self.activity.stopAnimating()
                    self.okBun.isEnabled = true
                    self.okBun.tintColor?.withAlphaComponent(1)
                }
            case .sending:
                print("APN 设置发送数据中")
            }
        }
    }
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
    
}





