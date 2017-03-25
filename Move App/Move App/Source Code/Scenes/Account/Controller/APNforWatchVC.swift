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
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var manager: CBCentralManager?
    var currentPeripheral: CBPeripheral?
    var currentCharacteristic: CBCharacteristic?
    
    var devices: Array<CBPeripheral> = []
    
    fileprivate let apnUUID = "00003333-0000-1000-8000-00805f9b34fb"
    fileprivate let apnService = "00009999-0000-1000-8000-00805f9b34fb"
    fileprivate let apnCharacteristic = "00009998-0000-1000-8000-00805f9b34fb"
    fileprivate let maxWriteLength = 20
   
    
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
        
        tableView.delegate = self
        
        let queue = DispatchQueue(label: "com.apn.myqueue")
        manager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true, CBCentralManagerOptionShowPowerAlertKey: false])
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = R.segue.aPNforWatchVC.showAPNSetting(segue: segue)?.destination {
            vc.settingDataBlock = { data in
                if let d = data {
                    self.currentPeripheral?.writeValue(d, for: self.currentCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
    
    
    
    deinit {
        if currentPeripheral != nil {
            currentPeripheral?.delegate = nil
            manager?.cancelPeripheralConnection(currentPeripheral!)
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
            let vc = UIAlertController(title: nil, message: "Turn on Bluetooth to Allow \"MOVETIME\" to connect to watch", preferredStyle: UIAlertControllerStyle.alert)
            let action1 = UIAlertAction(title: "Settings", style: .default) { action in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
            let action2 = UIAlertAction(title: "Ok", style: .default, handler: nil)
            vc.addAction(action1)
            vc.addAction(action2)
            self.present(vc, animated: true) {
                
            }
        default:
            break;
        }
    }
    
//    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
//        if dict[CBCentralManagerOptionRestoreIdentifierKey] as? String ==  "currentDeviceIdentify" {
//            print("找到需要恢复的连接")
//        }
//    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if self.devices.contains(peripheral) {
            return
        }else {
            self.devices.append(peripheral)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.manager?.stopScan()
        print("设备连接成功，扫描服务...")
        self.currentPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: apnService)])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接设备失败" + error.debugDescription)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙设备解绑:\(peripheral)")
    }

}



extension APNforWatchVC: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for ser in peripheral.services ?? [] {
            if ser.uuid == CBUUID(string: apnService) {
                peripheral.discoverCharacteristics([CBUUID(string: apnCharacteristic)], for: ser)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for ch in service.characteristics ?? [] {
            if ch.uuid == CBUUID(string: apnCharacteristic) {
                print("找到特征值,待写入数据")
                self.currentCharacteristic = ch
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: R.segue.aPNforWatchVC.showAPNSetting, sender: nil)
                }
                peripheral.readValue(for: ch)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        print(data == nil ? "特征无数据":"特征有数据")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error.debugDescription)
            print("发送数据失败")
        }else{
            print("发送数据成功")
        }
        
        /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
        peripheral.readValue(for: characteristic)
    }
    
    
}


extension APNforWatchVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "reuseIdentifier")
        }
        
        let per = self.devices[indexPath.row]
        cell?.textLabel?.text = per.name
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pers = manager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: apnService)]) {
            for p in pers {
                p.delegate = nil
                manager?.cancelPeripheralConnection(p)
            }
        }
        
        let per = self.devices[indexPath.row]
        
        let vc = UIAlertController(title: nil, message: "Connect to \(per.name ?? "")", preferredStyle: UIAlertControllerStyle.alert)
        let action1 = UIAlertAction(title: "Cancel", style: .default) { action in
            
        }
        let action2 = UIAlertAction(title: "YES", style: .default) { action in
            self.manager?.connect(per, options: nil)
        }
        vc.addAction(action1)
        vc.addAction(action2)
        self.present(vc, animated: true) {
            
        }
    }

}
