//
//  MoveApiDeviceWorker.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class MoveApiDeviceWorker: DeviceWorkerProtocl {
    
    func addDevice(firstBindInfo: DeviceFirstBindInfo) -> Observable<Bool> {
        var addInfo = MoveApi.DeviceAdd()
        addInfo.sid = firstBindInfo.sid
        addInfo.vcode = firstBindInfo.vcode
        addInfo.phone = firstBindInfo.phone
        addInfo.identity = MoveApi.DeviceAddIdentity.transform(input:(firstBindInfo.identity?.rawValue)!)
        addInfo.profile = firstBindInfo.profile
        addInfo.nickName = firstBindInfo.nickName
        addInfo.number = firstBindInfo.number
        addInfo.gender = firstBindInfo.gender
        addInfo.height = firstBindInfo.height
        addInfo.weight = firstBindInfo.weight
        addInfo.birthday = firstBindInfo.birthday
        return MoveApi.Device.add(deviceId: firstBindInfo.deviceId!, addInfo: addInfo)
            .map {info in
                if info.msg == "ok", info.id == 0 {
                    return true
                }
                throw WorkerError.webApi(id: info.id!, field: info.field, msg: info.msg)
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
}

