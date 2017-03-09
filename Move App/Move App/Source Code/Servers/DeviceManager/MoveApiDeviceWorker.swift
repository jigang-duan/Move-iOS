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
    
    func checkBind(deviceId: String) -> Observable<Bool> {
        return MoveApi.Device.checkBind(deviceId: deviceId)
            .map({$0.bind ?? true})
    }
    
    func addDevice(firstBindInfo: DeviceBindInfo) -> Observable<Bool> {
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
    
    func joinGroup(joinInfo: DeviceBindInfo) -> Observable<Bool> {
        var info = MoveApi.DeviceJoinInfo()
        info.identity = MoveApi.DeviceAddIdentity.transform(input:(joinInfo.identity?.rawValue)!)
        info.phone = joinInfo.phone
        info.profile = joinInfo.profile
    
        return MoveApi.Device.joinDeviceGroup(deviceId: joinInfo.deviceId!, joinInfo: info)
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
    
    
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]> {
        return MoveApi.Device.getDeviceList()
                .map({ $0.devices ?? [] })
    }
}

