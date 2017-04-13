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
    
    var currentDevice: DeviceInfo? {
        get {
            let id = RxStore.shared.currentDeviceId.value
            return RxStore.shared.deviceInfosState.value.filter({ $0.deviceId == id }).first
        }
        set(newValue) {
            let id = newValue?.deviceId
            if RxStore.shared.deviceInfosState.value.contains(where: { $0.deviceId == id}) {
                RxStore.shared.currentDeviceId.value = id
            }
        }
    }
    
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
    
    func fetchDevices() -> Observable<[DeviceInfo]> {
        return worker.getDeviceList().map({ $0.map({ DeviceInfo(element: $0) }) })
    }
    
    func fetchDevice(id: String) -> Observable<DeviceInfo> {
        return worker.fetchDevice(deviceId: id)
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
    
    func remindLocation(deviceId: String) -> Observable<Bool> {
        return sendNotify(deviceId: deviceId, code: .uploadLocation)
    }
    
    func sendNotify(deviceId: String, code: DeviceNotify) -> Observable<Bool> {
        return worker.sendNotify(deviceId: deviceId, code: code)
    }
    
    func addNoRegisterMember(deviceId: String, phone: String, profile: String?, identity: Relation) -> Observable<Bool>  {
        return worker.addNoRegisterMember(deviceId: deviceId, phone: phone, profile: profile, identity: identity)
    }
}


protocol DeviceWorkerProtocl {
    
    func checkBind(deviceId: String) -> Observable<Bool>
    
    func addDevice(firstBindInfo: DeviceBindInfo) -> Observable<Bool>
    
    func joinGroup(joinInfo: DeviceBindInfo) -> Observable<Bool>
    
    func getDeviceList() -> Observable<[MoveApi.DeviceInfo]>
    
    func fetchDevice(deviceId: String) -> Observable<DeviceInfo>
    
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
    func sendNotify(deviceId: String, code: DeviceNotify) -> Observable<Bool>
    
    func addNoRegisterMember(deviceId: String, phone: String, profile: String?, identity: Relation) -> Observable<Bool>
}


struct DeviceInfo {
    var pid: Int?
    var deviceId: String?
    var user: DeviceUser?
    var property: DeviceProperty?
}

extension DeviceInfo {

    init(element: MoveApi.DeviceInfo) {
        self.init()
        self.deviceId = element.deviceId
        self.pid = element.pid
        self.user = DeviceUser(uid: element.user?.uid,
                               number: element.user?.number,
                               nickname: element.user?.nickname,
                               profile: element.user?.profile,
                               gender: element.user?.gender,
                               height: element.user?.height,
                               weight: element.user?.weight,
                               birthday: element.user?.birthday,
                               gid: element.user?.gid)
    }
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
    var maxgroups: Int?
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


enum DeviceNotify: Int{
//    1 - 请求设备上报位置，由APP发送
//    2 - 请求设备下载固件
//    101 - 设备开机
//    102 - 设备关机
//    103 - 低电量, value为当前电量
//    104 - SOS
//    105 - 漫游
//    106 - 固件升级成功, value为当前版本号
//    107 - 固件下载进度，value为下载进度百分比
//    108 - 设备穿戴
//    109 - 设备脱落
//    110 - 设备更换号码
    case uploadLocation = 1
    case downloadFirmware = 2
    case devicePowerOn = 101
    case devicePowerOff = 102
    case deviceLowPower = 103
}









