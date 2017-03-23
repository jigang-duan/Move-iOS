//
//  APNforWatchVC.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import CoreBluetooth


class APNforWatchVC: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var cbReady = false
    var batteryValue: Float?
    var manager: CBCentralManager?
    var currentPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    var devices: Array<CBPeripheral> = []
    var services: Array<Any>?
    var characteristics: Array<Any>?
    
    fileprivate let apnUUID = "00003333-0000-1000-8000-00805f9b34fb"
    fileprivate let apnService = "00009999-0000-1000-8000-00805f9b34fb"
    fileprivate let apnCharacteristic = "00009998-0000-1000-8000-00805f9b34fb"
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        
        let queue = DispatchQueue(label: "com.apn.myqueue")
        manager = CBCentralManager(delegate: self, queue: queue)
        
    }
    
    
    
    
    
    func showMessage(_ text: String) {
        let vc = UIAlertController.init(title: "提示", message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        vc.addAction(action)
        self.present(vc, animated: true) {
            
        }
    }
    
    
}

extension APNforWatchVC: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            print("蓝牙已打开,请扫描外设")
            manager?.scanForPeripherals(withServices: [CBUUID(string: apnUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false, CBCentralManagerOptionShowPowerAlertKey: true, CBCentralManagerOptionRestoreIdentifierKey: "currentDeviceIdentify"])
            break;
        case .poweredOff:
            print("蓝牙没有打开,请先打开蓝牙")
            break;
        default:
            break;
        }
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.devices.append(peripheral)
        self.tableView.reloadData()
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.manager?.stopScan()
        self.showMessage("设备连接成功，扫描服务...")
        self.currentPeripheral?.discoverServices([CBUUID(string: apnService)])
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error.debugDescription)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙设备解绑")
    }

}



extension APNforWatchVC: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for ser in peripheral.services ?? [] {
            if ser.uuid == CBUUID(string: apnService) {
                peripheral.discoverServices([CBUUID(string: apnService)])
                self.showMessage("找到服务，查找特征中...")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for ch in service.characteristics ?? [] {
            if ch.uuid == CBUUID(string: apnCharacteristic) {
                self.showMessage("找到特征值,待写入数据")
                peripheral.readValue(for: ch)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let data = characteristic.value
        self.showMessage(data == nil ? "特征无数据":"特征有数据")
//        let bytes = data?.copyBytes(to: <#T##UnsafeMutableBufferPointer<DestinationType>#>)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error.debugDescription)
        }else{
            self.showMessage("发送数据成功")
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
        self.currentPeripheral = self.devices[indexPath.row]
        self.manager?.connect(self.currentPeripheral!, options: nil)
    }

}
