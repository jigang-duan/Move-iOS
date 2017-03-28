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
    
    let transSymbol: UInt8 = 0xDD//转译符
    
    let beginSymbol: UInt8 = 0xFF//开始符
    let endSymbol: UInt8 = 0x55//结束符
    
    /*
     蓝牙数据结构  |-----最大20长度-----|
     |开始符|总包|第几包|数据长度|---数据---|CRC16|结束符|
    */
    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var resultData: Data?
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.apnSettingNotification(_:)), name: NSNotification.Name(rawValue: APNforWatchVC.ApnDoneNotification), object: nil)
        
        let str = APNforWatchVC.APNData(plmn: "1", apn: "2", spn: "3", user: "4", password: "5", proxy: "6", port: "7", authtype: "8").toJSONString()
        let data = str?.data(using: String.Encoding.utf8)
        
        
        
        
        let transData = self.dataTrans(with: data!)
        resultData = self.generateTargetData(data: transData)
        
        

        
        activity.center = self.view.center
        self.view.addSubview(activity)
        
       
    }
    
    @IBAction func sendAPNSettings(_ sender: Any) {
        activity.startAnimating()
        
        okBun.isEnabled = false
        okBun.tintColor?.withAlphaComponent(0.5)
        
        if self.settingDataBlock != nil {
            self.settingDataBlock!(resultData)
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
                }
            case .xxx:
                DispatchQueue.main.async {
                    self.showMessage("APN 找到特征")
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
    
    
//    数据转译
    func dataTrans(with data: Data) -> Data {
        
        var tempData = Data()
        
        for byte in data {
            if byte == transSymbol || byte == beginSymbol || byte == endSymbol {
                tempData.append(byte)
            }
            tempData.append(byte)
        }
    
        return tempData
    }
    
//    数据分包
    func generateTargetData(data: Data) -> Data {
        var resultData = Data()
//        总包数
        let totalBag = data.count/13 + (data.count%13 == 0 ? 0:1)
        
        for i in 0..<totalBag {
            resultData.append(beginSymbol)//开始符
            resultData.append(UInt8(totalBag))//总包
            resultData.append(UInt8(i + 1))//第几包
            var tempData: Data?
            if i == totalBag - 1 {
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*13, upper: data.count)))
                resultData.append(UInt8(data.count - i*13))//长度
            }else{
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*13, upper: i*13 + 13)))
                resultData.append(UInt8(13))//长度
            }
            tempData?.append(CRC16.GetCRC(data: tempData!))//数据CRC处理
            resultData.append(tempData!)//数据
            resultData.append(endSymbol)//结束符
        }
        return resultData
    }
    
    
}





