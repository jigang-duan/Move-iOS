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
    
    func checkBind(deviceId: String) -> Observable<Bool> {
        return worker.checkBind(deviceId: deviceId)
    }
    
    func addDevice(firstBindInfo: DeviceBindInfo) -> Observable<Bool>{
        return worker.addDevice(firstBindInfo: firstBindInfo)
    }
    
    func joinGroup(joinInfo: DeviceBindInfo) -> Observable<Bool> {
        return worker.joinGroup(joinInfo: joinInfo)
    }
   
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]>  {
        return worker.getDeviceList()
    }
    
    func setCurrentDevice(deviceInfo: DeviceInfo) -> Observable<DeviceInfo> {
        self.currentDevice = deviceInfo
        Me.shared.currDeviceID = deviceInfo.deviceId
        return Observable.just(deviceInfo)
    }
    
    func deleteContact(deviceId: String, uid: String) -> Observable<Bool> {
        return worker.deleteContact(deviceId: deviceId, uid: uid)
    }
    
    func getContacts(deviceId: String) -> Observable<[ImContact]> {
        return worker.getContacts(deviceId: deviceId)
    }
    
    func settingContactInfo(deviceId: String, contactInfo: ImContact) -> Observable<Bool> {
        return worker.settingContactInfo(deviceId: deviceId, contactInfo: contactInfo)
    }
    
    func updateKidInfo(updateInfo: DeviceUser) -> Observable<Bool> {
        return worker.updateKidInfo(updateInfo: updateInfo)
    }
    
    func deleteDevice(with deviceId: String) -> Observable<Bool> {
        return worker.deleteDevice(with: deviceId)
    }
    
    func settingAdmin(deviceId: String, uid: String) -> Observable<Bool> {
        return worker.settingAdmin(deviceId: deviceId, uid: uid)
    }
    
    func getWatchFriends(with deviceId: String) -> Observable<[DeviceFriend]> {
        return worker.getWatchFriends(with: deviceId)
    }
    
    func deleteWatchFriend(deviceId: String, uid: String) -> Observable<Bool> {
        return worker.deleteWatchFriend(deviceId: deviceId, uid: uid)
    }
    
    func checkVersion(checkInfo: DeviceVersionCheck)  -> Observable<DeviceVersion> {
        return worker.checkVersion(checkInfo: checkInfo)
    }
    
    func getProperty(deviceId: String)  -> Observable<DeviceProperty> {
        return worker.getProperty(deviceId: deviceId)
    }
    
}


protocol DeviceWorkerProtocl {
    
    func checkBind(deviceId: String) -> Observable<Bool>
    
    func addDevice(firstBindInfo: DeviceBindInfo) -> Observable<Bool>
    
    func joinGroup(joinInfo: DeviceBindInfo) -> Observable<Bool>
    
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]>
    
    func deleteContact(deviceId: String, uid: String) -> Observable<Bool>
    
    func getContacts(deviceId: String) -> Observable<[ImContact]>
    
    func settingContactInfo(deviceId: String, contactInfo: ImContact) -> Observable<Bool>
    
    func updateKidInfo(updateInfo: DeviceUser) -> Observable<Bool>
    
    func deleteDevice(with deviceId: String) -> Observable<Bool>
    
    func settingAdmin(deviceId: String, uid: String) -> Observable<Bool>
    func getWatchFriends(with deviceId: String) -> Observable<[DeviceFriend]>
    func deleteWatchFriend(deviceId: String, uid: String) -> Observable<Bool>
    
    func checkVersion(checkInfo: DeviceVersionCheck)  -> Observable<DeviceVersion>
    
    func getProperty(deviceId: String)  -> Observable<DeviceProperty>
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
    var gid: String?
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

struct DeviceBindInfo {
    var isMaster: Bool?
    var deviceId: String?
    var sid: String?
    var vcode: String?
    var phone: String? //用户号码
    var identity: Relation?
    var profile: String?
    var nickName: String?
    var number: String? //设备号码
    var gender: String?
    var height: Int?
    var weight: Int?
    var birthday: Date?
}


struct DeviceFriend {
    var uid: String?
    var nickname: String?
    var profile: String?
    var phone: String?
}

struct DeviceVersionCheck {
    var deviceId: String?
    var mode: String?
    var cktp: String?
    var curef: String?
    var cltp: String?
    var type: String?
    var fv: String?
}

struct DeviceVersion {
    var currentVersion: String?
    var newVersion: String?
}
