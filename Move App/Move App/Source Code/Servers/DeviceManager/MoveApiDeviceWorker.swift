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
        addInfo.identity = firstBindInfo.identity?.transformToString()
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
        var info = MoveApi.DeviceContactInfo()
        info.identity = joinInfo.identity?.transformToString()
        info.phone = joinInfo.phone
    
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
    
    //        删除设备联系人:  解绑设备的绑定成员，仅设备管理员调用
    func deleteContact(deviceId: String, uid: String) -> Observable<Bool> {
        return MoveApi.Device.deleteBindUser(deviceId: deviceId, uid: uid)
            .map{info in
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
    //        设置联系人信息:  由管理员或联系人自己调用
    func settingContactInfo(deviceId: String, contactInfo: ImContact) -> Observable<Bool> {
        var info = MoveApi.DeviceContactInfo()
        info.flag = contactInfo.flag
        info.identity = contactInfo.identity?.transformToString()
        info.phone = contactInfo.phone
        
        return MoveApi.Device.settingContactInfo(deviceId: deviceId, info: info, uid: contactInfo.uid!)
            .map{info in
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
    
    
    func updateKidInfo(updateInfo: DeviceUser) -> Observable<Bool> {
        var info = MoveApi.DeviceUpdateReq()
        info.device = MoveApi.DeviceUpdateInfo()
        info.device?.user = MoveApi.DeviceUser()
        info.device?.user?.nickname = updateInfo.nickname
        info.device?.user?.number = updateInfo.number
        info.device?.user?.profile = updateInfo.profile
        info.device?.user?.gender = updateInfo.gender
        info.device?.user?.height = updateInfo.height
        info.device?.user?.weight = updateInfo.weight
        info.device?.user?.birthday = updateInfo.birthday
        
        return MoveApi.Device.update(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!, updateInfo: info)
            .map{info in
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
    
    
    
    func deleteDevice(with deviceId: String) -> Observable<Bool> {
        return MoveApi.Device.delete(deviceId: deviceId)
            .map{info in
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















