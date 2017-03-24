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
        manager = CBCentralManager(delegate: self, queue: queue)
        
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
    
    
    
//    func showMessage(_ text: String) {
//        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
//        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
//        vc.addAction(action)
//        self.present(vc, animated: true) {
//            
//        }
//    }
    
    
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
            print("蓝牙已打开,请扫描外设")
            manager?.scanForPeripherals(withServices: [CBUUID(string: apnUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            break;
        case .poweredOff:
            print("蓝牙没有打开,请先打开蓝牙")
            break;
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
            self.tableView.reloadData()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.manager?.stopScan()
        print("设备连接成功，扫描服务...")
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
                let str = APNData(plmn: "1", apn: "2", spn: "3", user: "4", password: "5", proxy: "6", port: "7", authtype: "8").toJSONString()
                let data = str?.data(using: String.Encoding.utf8)
                peripheral.writeValue(data!, for: ch, type: CBCharacteristicWriteType.withResponse)
                
                
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
        
        self.currentPeripheral = self.devices[indexPath.row]
        self.currentPeripheral?.delegate = self
        self.manager?.connect(self.currentPeripheral!, options: nil)
    }

}
