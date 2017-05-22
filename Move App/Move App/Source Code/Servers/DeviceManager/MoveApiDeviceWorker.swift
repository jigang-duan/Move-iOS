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
            .catchError(errorHandle)
    }
    
    func addDevice(firstBindInfo: DeviceBindInfo) -> Observable<Bool> {
        var addInfo = MoveApi.DeviceAdd()
        addInfo.sid = firstBindInfo.sid
        addInfo.vcode = firstBindInfo.vcode
        addInfo.phone = firstBindInfo.phone
        addInfo.identity = firstBindInfo.identity?.identity
        addInfo.profile = firstBindInfo.profile
        addInfo.nickName = firstBindInfo.nickName
        addInfo.number = firstBindInfo.number
        addInfo.gender = firstBindInfo.gender
        addInfo.height = firstBindInfo.height
        addInfo.weight = firstBindInfo.weight
        addInfo.heightUnit = firstBindInfo.heightUnit?.rawValue
        addInfo.weightUnit = firstBindInfo.weightUnit?.rawValue
        addInfo.birthday = firstBindInfo.birthday
        return MoveApi.Device.add(deviceId: firstBindInfo.deviceId!, addInfo: addInfo)
            .map(errorTransform)
            .catchError(errorHandle)
    }

    
    func joinGroup(joinInfo: DeviceBindInfo) -> Observable<Bool> {
        var info = MoveApi.DeviceContactInfo()
        info.identity = joinInfo.identity?.identity
        info.phone = joinInfo.phone
        info.profile = joinInfo.profile
    
        return MoveApi.Device.joinDeviceGroup(deviceId: joinInfo.deviceId!, joinInfo: info)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    
    func fetchDevice(deviceId: String) -> Observable<DeviceInfo> {
        return MoveApi.Device.getDeviceInfo(deviceId: deviceId).map({ DeviceInfo(element: $0) })
    }
    
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]> {
        return MoveApi.Device.getDeviceList().map({ $0.devices ?? [] })
    }
    
    
    //        添加设备联系人:  添加非注册用户为设备联系人，仅管理员调用
    func addNoRegisterMember(deviceId: String, phone: String, profile: String?, identity: Relation) -> Observable<Bool> {
        var info = MoveApi.DeviceContactInfo()
        info.phone = phone
        info.profile = profile
        info.identity = identity.identity
    
        return MoveApi.Device.addNoRegisterMember(deviceId: deviceId, contactInfo: info)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    //        删除设备联系人:  解绑设备的绑定成员，仅设备管理员调用
    func deleteContact(deviceId: String, uid: String) -> Observable<Bool> {
        return MoveApi.Device.deleteBindUser(deviceId: deviceId, uid: uid)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    //        获取设备联系人
    func getContacts(deviceId: String) -> Observable<[ImContact]> {
        return MoveApi.Device.getContacts(deviceId: deviceId)
            .map { info in
                 info.contacts?.map({ ImContact(uid: $0.uid,
                                               type: $0.type,
                                               username: $0.username,
                                               nickname: $0.nickname,
                                               profile: $0.profile,
                                               identity: ($0.identity == nil) ? nil : Relation(input: $0.identity!),
                                               phone: $0.phone,
                                               email: $0.email,
                                               time: $0.time,
                                               sex: $0.sex,
                                               flag: $0.flag,
                                               admin: $0.admin) }) ?? []
            }
    }
    
    //        设置联系人信息:  由管理员或联系人自己调用
    func settingContactInfo(deviceId: String, contactInfo: ImContact) -> Observable<Bool> {
        var info = MoveApi.DeviceContactInfo()
        info.flag = contactInfo.flag
        info.identity = contactInfo.identity?.identity
        info.phone = contactInfo.phone
        info.profile = contactInfo.profile
        
        return MoveApi.Device.settingContactInfo(deviceId: deviceId, info: info, uid: contactInfo.uid!)
            .map(errorTransform)
            .catchError(errorHandle)
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
        info.device?.user?.heightUnit = updateInfo.heightUnit?.rawValue
        info.device?.user?.weightUnit = updateInfo.weightUnit?.rawValue
        info.device?.user?.birthday = updateInfo.birthday
        
        return MoveApi.Device.update(deviceId: (DeviceManager.shared.currentDevice?.deviceId)!, updateInfo: info)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    
    
    func deleteDevice(with deviceId: String) -> Observable<Bool> {
        return MoveApi.Device.delete(deviceId: deviceId)
            .map(errorTransform)
            .catchError(errorHandle)
    }

    
    func settingAdmin(deviceId: String, uid: String) -> Observable<Bool> {
        return MoveApi.Device.settingAdmin(deviceId: deviceId, admin: MoveApi.DeviceAdmin(uid: uid))
            .map(errorTransform)
            .catchError(errorHandle)
    }

    
    func getWatchFriends(with deviceId: String) -> Observable<[DeviceFriend]> {
        return MoveApi.Device.getWatchFriends(deviceId: deviceId)
            .map{ $0.friends?.map{ DeviceFriend(uid: $0.uid, nickname: $0.nickname, profile: $0.profile, phone: $0.phone) } ?? [] }
    }

    
    func deleteWatchFriend(deviceId: String, uid: String) -> Observable<Bool> {
        return MoveApi.Device.deleteWatchFriend(deviceId: deviceId, uid: uid)
            .map(errorTransform)
            .catchError(errorHandle)
    }

    
    func checkVersion(checkInfo: DeviceVersionCheck)  -> Observable<DeviceVersion>{
        let check = MoveApi.DeviceVersionCheck(id: checkInfo.deviceId,
                                               mode: checkInfo.mode,
                                               cktp: checkInfo.cktp,
                                               curef: checkInfo.curef,
                                               cltp: checkInfo.cltp,
                                               type: checkInfo.type,
                                               fv: checkInfo.fv)
        return MoveApi.Device().checkVersion(checkInfo: check)
            .map{ DeviceVersion(currentVersion: $0.version?.fv, newVersion: $0.version?.tv) }
    }
    
    
    func getProperty(deviceId: String)  -> Observable<DeviceProperty>{
        return MoveApi.Device.getProperty(deviceId: deviceId).map {
            DeviceProperty(active: $0.active,
                           bluetooth_address: $0.bluetooth_address,
                           device_model: $0.device_model,
                           firmware_version: $0.firmware_version,
                           ip_address: $0.ip_address,
                           kernel_version: $0.kernel_version,
                           mac_address: $0.mac_address,
                           phone_number: $0.phone_number,
                           languages: $0.languages,
                           power: $0.power,
                           maxgroups: $0.maxgroups,
                           fota_sta: $0.fota_sta)
        }
    }
    
    
    
    //        发送提醒
    func sendNotify(deviceId: String, code: DeviceNotify) -> Observable<Bool> {
        return MoveApi.Device.sendNotify(deviceId: deviceId, sendInfo: MoveApi.DeviceSendNotify(code: code.rawValue, value: nil)).map { $0.id == 0 }
    }
    
    //        获取时区信息
    func fetchTimezones(lng: String?, lat: String?) -> Observable<[TimezoneInfo]> {
        return MoveApi.Device.fetchTimezones(lng: lng, lat: lat)
            .map {infos in infos.map{ (info) in TimezoneInfo(id: info.id, lng: info.lng, lat: info.lat, gmtoffset: info.gmtoffset, countryname: info.countryname, timezoneId: info.timezoneId) } }
    }
    
    func fetchPower(deviceId: String) -> Observable<Int> {
        return MoveApi.Device.getPower(deviceId: deviceId).map{ $0.power }.filterNil()
    }
}







