//
//  MeManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

/// User Me Protocl
protocol MeWorkerProtocl {
}


class MeManager {
    static let shared = MeManager()
    
    fileprivate var worker: MeWorkerProtocl!
    
    init() {
        worker = MoveApiMeWorker()
    }
    
    func checkCurrentRole() -> Observable<String?> {
        return DeviceManager.shared.fetchDevices()
            .map { $0.first }
            .flatMapLatest { (it) -> Observable<DeviceInfo> in
                guard
                    let device = it,
                    let _ = device.deviceId else {
                    throw WorkerError.deviceNo
                }
                return DeviceManager.shared.setCurrentDevice(deviceInfo: device)
            }
            .map { $0.deviceId }
    }
    
}

extension UserManager {
    
    func isValid() -> Observable<Bool> {
        
        return UserInfo.shared.isValid()
        
    }
    
}
