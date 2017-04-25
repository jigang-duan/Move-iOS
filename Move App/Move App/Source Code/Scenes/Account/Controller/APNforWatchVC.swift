//
//  APNforWatchVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CoreBluetooth
import ObjectMapper


class APNforWatchVC: UIViewController {
    
    @IBOutlet weak var helpImgV: UIImageView!
    @IBOutlet weak var helpHCons: NSLayoutConstraint!
    
    @IBOutlet weak var deviceNameLab: UILabel!
    
    @IBOutlet weak var deviceView: UIView!
    @IBOutlet weak var deviceHCons: NSLayoutConstraint!
    
    
    var hasPairedWatch = false///是否已绑定手表
    var imei = ""
    
    static let ApnNotification = "ApnNotification"
    
    var manager: CBCentralManager?
    var currentCharacteristic: CBCharacteristic?
    
    var targetPeripheral: CBPeripheral?
    
    fileprivate let apnUUID = "00003333-0000-1000-8000-00805f9b34fb"
    fileprivate let apnService = "00009999-0000-1000-8000-00805f9b34fb"
    fileprivate let apnCharacteristic = "00009998-0000-1000-8000-00805f9b34fb"
    fileprivate let apnCharacteristicReceive = "00009997-0000-1000-8000-00805f9b34fb"
    fileprivate let maxWriteLength = 20
   
    
    var willWriteData: Data?
    var writeIndex = 0
    
    
    var response = ApnResponse()
    
    struct ApnResponse {
        var data = Data()
        var bagIndex = 0
    }
    
    
    enum ApnSettingResult {
        case fecthApn(apnData: APNData)
        case sending
        case error
        case sendDone
        case setSuccess
        case setFail
        case disconnect
    }
    
    
    struct APNData {
        var plmn: String?
        var apn: String?
        var spn: String?
        var user: String?
        var password: String?
        var proxy: String?
        var port: String?
        var authtype: String?
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if hasPairedWatch == true {
            helpHCons.constant = UIScreen.main.bounds.size.width*188/375
        }else{
            helpHCons.constant = 0
            helpImgV.isHidden = true
        }
        
        deviceView.isHidden = true
        deviceHCons.constant = 0
        
        
        let queue = DispatchQueue(label: "com.apn.myqueue")
        manager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true, CBCentralManagerOptionShowPowerAlertKey: false])
        
    }
    
 
    @IBAction func tapToPair(_ sender: Any) {
        if let pp = targetPeripheral {
            if let pers = manager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: apnService)]) {
                for p in pers {
                    p.delegate = nil
                    manager?.cancelPeripheralConnection(p)
                }
            }
            
            let vc = UIAlertController(title: nil, message: "Connect to \(deviceNameLab.text ?? "")", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Cancel", style: .default)
            
            let action2 = UIAlertAction(title: "YES", style: .default) {[weak self] _ in
                self?.manager?.connect(pp, options: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                    
                    let peripherals = self?.manager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: (self?.apnService)!)])
                    if peripherals?.contains(pp) == false {
                        self?.manager?.cancelPeripheralConnection(pp)
                        self?.showFailToPair()
                    }
                })
            }
            vc.addAction(action1)
            vc.addAction(action2)
            self.present(vc, animated: true)
        }
    }
    
    
    func showFailToPair() {
        let vc = UIAlertController(title: "Bluetooth Pairing Failed", message: "Can not pair this watch, please check the watch again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        vc.addAction(action)
        self.present(vc, animated: true)
    }
    
    
    func sendApnNotification(_ notify: ApnSettingResult) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: APNforWatchVC.ApnNotification), object: notify)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //setting
        if let vc = R.segue.aPNforWatchVC.showAPNSetting(segue: segue)?.destination {
            vc.settingDataBlock = { data in
                if let d = data {
                    self.willWriteData = d
                    self.writeIndex = 0
                    self.writeApnData()
                }
            }
            
            vc.requestSettingsBlock = { data in
                self.willWriteData = data
                self.writeIndex = 0
                self.writeApnData()
            }
        }
        
        
        //help
        if let vc = R.segue.aPNforWatchVC.showHelp(segue: segue)?.destination {
            vc.isPaired = hasPairedWatch
        }
        
        
    }
    
    
    func writeApnData() {
        var tempData: Data!
        
        if writeIndex + 20 > (willWriteData?.count)! {
            tempData = willWriteData?.subdata(in: Range(uncheckedBounds: (lower: writeIndex, upper: (willWriteData?.count)!)))
            writeIndex = (willWriteData?.count)!
        }else{
            tempData = willWriteData?.subdata(in: Range(uncheckedBounds: (lower: writeIndex, upper: writeIndex + 20)))
            writeIndex += 20
        }
        self.targetPeripheral?.writeValue(tempData, for: self.currentCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    
    
    func apnSetResponde(data: Data) {
        
        let res = ApnBleTool.unPackage(data: data, currentBag: response.bagIndex)
        
        if res.isError {
            response = ApnResponse()
        }else{
            response.data.append(res.data)
            response.bagIndex = res.currentBag
        }
        if res.isDone {
            let resData = ApnBleTool.dataUntrans(with: response.data)
            
            switch res.type {
            case .setResult:
                if resData == Data(bytes: [0x01]) {
                    self.sendApnNotification(.setSuccess)
                }else{
                    self.sendApnNotification(.setFail)
                }
            case .receiveSetting:
                if let apnStr = String(data: resData, encoding: .utf8) {
                    if let apnSettings = Mapper<APNData>().map(JSONString: apnStr) {
                        self.sendApnNotification(.fecthApn(apnData: apnSettings))
                    }
                }
            default:
                break
            }
            
            response = ApnResponse()
        }
    }
    
    
    
    func gotoSettingApnVC() {
        if let vc = self.navigationController?.topViewController {
            if !(vc is APNSettingVC) {
                self.performSegue(withIdentifier: R.segue.aPNforWatchVC.showAPNSetting, sender: nil)
            }
        }
    }
    
    
    deinit {
        if targetPeripheral != nil {
            targetPeripheral?.delegate = nil
            manager?.cancelPeripheralConnection(targetPeripheral!)
        }
        if manager != nil {
            manager?.delegate = nil
            manager = nil
        }
    }
    
    
    
}

extension APNforWatchVC.APNData: Mappable {
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map){
        plmn <- map["plmn"]
        apn <- map["apn"]
        spn <- map["spn"]
        user <- map["user"]
        password <- map["password"]
        proxy <- map["proxy"]
        port <- map["port"]
        authtype <- map["authtype"]
    }
}


extension APNforWatchVC: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            manager?.scanForPeripherals(withServices: [CBUUID(string: apnUUID)], options: nil)
        case .poweredOff:
            let vc = UIAlertController(title: nil, message: "Turn on Bluetooth to Allow \"MOVETIME\" to connect to watch", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Settings", style: .default) { _ in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            let action2 = UIAlertAction(title: "Ok", style: .default)
            vc.addAction(action1)
            vc.addAction(action2)
            self.present(vc, animated: true)
        default:
            break;
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.imei.characters.count > 4 {
            let lastImei = imei.substring(from: imei.index(imei.endIndex, offsetBy: -4))
            let watchName = "Family watch \(lastImei)"
            
            if watchName == peripheral.name {
                print("找到目标设备")
                manager?.stopScan()
                targetPeripheral = peripheral
                
                DispatchQueue.main.async {
                    self.deviceView.isHidden = false
                    self.deviceHCons.constant = 50
                    self.deviceNameLab.text = watchName
                }
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("设备连接成功，扫描服务...")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: apnService)])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接设备失败" + error.debugDescription)
        self.showFailToPair()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙设备解绑:\(peripheral)")
        self.sendApnNotification(.disconnect)
    }

}



extension APNforWatchVC: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for ser in peripheral.services ?? [] {
            if ser.uuid == CBUUID(string: apnService) {
                peripheral.discoverCharacteristics([CBUUID(string: apnCharacteristic),CBUUID(string: apnCharacteristicReceive)], for: ser)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for ch in service.characteristics ?? [] {
            if ch.uuid == CBUUID(string: apnCharacteristic) {
                print("找到写入数据特征值")
                self.currentCharacteristic = ch
                DispatchQueue.main.async {
                    self.gotoSettingApnVC()
                }
            }
            
            if ch.uuid == CBUUID(string: apnCharacteristicReceive) {
                print("找到接收数据特征值")
                peripheral.setNotifyValue(true, for: ch)
                peripheral.readValue(for: ch)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: apnCharacteristicReceive) {
            if let d = characteristic.value {
                self.apnSetResponde(data: d)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("发送数据失败" + error.debugDescription)
            self.sendApnNotification(.error)
        }else{
            print("发送数据成功")
            if writeIndex == willWriteData?.count {
                writeIndex = 0
                self.sendApnNotification(.sendDone)
            }else{
                self.sendApnNotification(.sending)
                self.writeApnData()
            }
        }
    }
    
    
}
