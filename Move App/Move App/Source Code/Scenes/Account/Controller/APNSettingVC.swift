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
 
    
    
    let transSymbol: UInt8 = 0x70
    
    
    let beginSymbol: UInt8 = 0xFF
    let endSymbol: UInt8 = 0xFF
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let str = APNforWatchVC.APNData(plmn: "1", apn: "2", spn: "3", user: "4", password: "5", proxy: "6", port: "7", authtype: "8").toJSONString()
        let data = str?.data(using: String.Encoding.utf8)
        
        
        
        
        let transData = self.dataTrans(with: data!)
        let resultData = self.generateTargetData(data: transData)
        
        
//        if self.settingDataBlock != nil {
//            self.settingDataBlock!(resultData)
//        }
        
        
    }
    
    
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
    
    
    func generateTargetData(data: Data) -> Data {
        var resultData = Data()
        
//        总包数
        let totalBag = data.count/14 + (data.count%14 == 0 ? 0:1)
        
        for i in 0..<totalBag {
            resultData.append(beginSymbol)
            resultData.append(UInt8(totalBag))
            resultData.append(UInt8(i + 1))
            var tempData: Data?
            if i == totalBag - 1 {
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*14, upper: data.count)))
            }else{
                tempData = data.subdata(in: Range(uncheckedBounds: (lower: i*14, upper: i*14 + 14)))
            }
            tempData = self.makeCRC16(data: tempData!)
            resultData.append(tempData!)
            resultData.append(endSymbol)
        }
        
    
    
        
        
        return resultData
    }
    
    
    func makeCRC16(data: Data) -> Data {
        var resultData = Data()
        
        resultData.append(data)
        resultData.append(0xEE)
        resultData.append(0xEE)
        
        return resultData
    }
    
    
}





