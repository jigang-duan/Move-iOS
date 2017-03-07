//
//  DeviceManager.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class DeviceManager {
    
    static let shared = DeviceManager()
    
    var currentDevice: DeviceInfo?
    
    fileprivate var worker: DeviceWorkerProtocl!
    
    init() {
        worker = MoveApiDeviceWorker()
    }
}

extension DeviceManager {
    
    func addDevice(firstBindInfo: DeviceFirstBindInfo) -> Observable<Bool>{
        return worker.addDevice(firstBindInfo: firstBindInfo)
    }
   
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]>  {
        return worker.getDeviceList()
    }
}


protocol DeviceWorkerProtocl {
    
    func addDevice(firstBindInfo: DeviceFirstBindInfo) -> Observable<Bool>
    
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]>
    
}


struct DeviceInfo {
    var pid: Int?
    var deviceId: String?
    var user: DeviceUser?
    var property: DeviceProperty?
}

struct DeviceUser {
    var uid: String?
    var number: String?
    var nickname: String?
    var profile: String?
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
}

struct DeviceProperty {
    var active: Bool?
    var bluetooth_address: String?
    var device_model :String?
    var firmware_version :String?
    var ip_address :String?
    var kernel_version :String?
    var mac_address :String?
    var phone_number :String?
    var languages: [String]?
    var power :Int?
}

struct DeviceFirstBindInfo {
    var deviceId: String?
    var sid: String?
    var vcode: String?
    var phone: String?
    var identity: Relation?
    var profile: String?
    var nickName: String?
    var number: String?
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
}
