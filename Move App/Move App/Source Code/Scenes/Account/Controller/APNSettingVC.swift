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
    var requestSettingsBlock: ((Data) -> Void)?
    
    @IBOutlet weak var plmnTf: UITextField!
    @IBOutlet weak var apnTf: UITextField!
    @IBOutlet weak var spnTf: UITextField!
    
    @IBOutlet weak var userTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    
    @IBOutlet weak var proxyAddTf: UITextField!
    @IBOutlet weak var proxyPortTf: UITextField!
    
    @IBOutlet weak var authSegment: UISegmentedControl!
 
    
    @IBOutlet weak var saveBun: UIBarButtonItem!
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initializeI18N() {
        self.title = R.string.localizable.id_set_apn()
        
        saveBun.title = R.string.localizable.id_save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeI18N()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apnSettingNotification(_:)), name: NSNotification.Name(rawValue: APNforWatchVC.ApnNotification), object: nil)
        
        
        authSegment.selectedSegmentIndex = 0
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        
        self.fetchWtachAPN()
    }
    
    
    func fetchWtachAPN() {
        let resultData = ApnBleTool.package(data: Data(bytes: [0x01]), type: .requestAPN)
        if self.requestSettingsBlock != nil {
            self.requestSettingsBlock!(resultData)
        }
    }
    
    
    func canEditApn(flag: Bool) {
        plmnTf.isEnabled = flag
        apnTf.isEnabled = flag
        spnTf.isEnabled = flag
        userTf.isEnabled = flag
        passwordTf.isEnabled = flag
        proxyAddTf.isEnabled = flag
        proxyPortTf.isEnabled = flag
        authSegment.isEnabled = flag
    }
    
    
    @IBAction func sendAPNSettings(_ sender: UIBarButtonItem) {
        
        if sender.title == R.string.localizable.id_edit(){
            self.canEditApn(flag: true)
            
            sender.title = R.string.localizable.id_save()
            
            return
        }
        
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
            self.canEditApn(flag: false)
            
            self.view.endEditing(true)
            
            activity.startAnimating()
            saveBun.isEnabled = false
            saveBun.tintColor?.withAlphaComponent(0.5)
            
            let transData = ApnBleTool.dataTrans(with: d)
            let resultData = ApnBleTool.package(data: transData, type: .sendAPNSetting)
            
            if self.settingDataBlock != nil {
                self.settingDataBlock!(resultData)
            }
        }
    }
    
    
    func showApnDatas(with data: APNforWatchVC.APNData) {
        plmnTf.text = data.plmn
        apnTf.text = data.apn
        spnTf.text = data.spn
        userTf.text = data.user
        passwordTf.text = data.password
        proxyAddTf.text = data.proxy
        proxyPortTf.text = data.port
        
        switch data.authtype ?? "" {
        case "Normal":
            authSegment.selectedSegmentIndex = 0
        case "PAP":
            authSegment.selectedSegmentIndex = 1
        case "CHAP":
            authSegment.selectedSegmentIndex = 2
        default:
            break
        }
    }
    
    
    func apnSettingNotification(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            if let res = notification.object as? APNforWatchVC.ApnSettingResult {
                switch res {
                case .fecthApn(let apnData):
                    self.showApnDatas(with: apnData)
                case .setSuccess:
                    self.showApnMessage(R.string.localizable.id_upload_completed())
                    self.activity.stopAnimating()
                    self.saveBun.isEnabled = true
                    self.saveBun.tintColor?.withAlphaComponent(1)
                    self.saveBun.title = R.string.localizable.id_edit()
                case .setFail:
                    self.showApnMessage(R.string.localizable.id_upload_failed())
                    self.activity.stopAnimating()
                    self.saveBun.isEnabled = true
                    self.saveBun.tintColor?.withAlphaComponent(1)
                    self.canEditApn(flag: true)
                case .sendDone:
                    print("APN 数据发送完成")
                case .error:
                    self.showApnMessage(R.string.localizable.id_upload_failed())
                    self.activity.stopAnimating()
                    self.saveBun.isEnabled = true
                    self.saveBun.tintColor?.withAlphaComponent(1)
                    self.canEditApn(flag: true)
                case .sending:
                    print("APN 发送数据中...")
                case .disconnect:
                    let vc = UIAlertController(title: nil, message: R.string.localizable.id_bluetooth_disconnected(), preferredStyle: .alert)
                    let action = UIAlertAction(title: R.string.localizable.id_ok(), style: .cancel, handler: { _ in
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    vc.addAction(action)
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    
    func showApnMessage(_ text: String) {
        ProgressHUD.show(status: text)
    }
    
    
    
}





