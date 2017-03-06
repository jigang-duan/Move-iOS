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
