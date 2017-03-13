//
//  MoveApi+Device+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct DeviceBind {
        var bind: Bool?
    }
    
    struct DeviceAdd {
        var sid: String?
        var vcode: String?
        var phone: String?
        var identity: String?
        var profile: String?
        var nickName: String?
        var number: String?
        var gender: String?
        var height: Int?
        var weight: Int?
        var birthday: Date?
    }
    
    struct DeviceContactInfo {
        var phone: String?
        var identity: String?
        var flag: Int?
    }
    
    
    struct DeviceGetListResp {
        var devices: [DeviceInfo]?
    }
    
    struct DeviceInfo {
        var pid: Int?
        var deviceId: String?
        var user: DeviceUser?
        var property: DeviceProperty?
    }
    
    struct DeviceUpdateReq {
        var device: DeviceUpdateInfo?
    }
    
    struct DeviceUpdateInfo {
        var user: DeviceUser?
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
    
    
    struct DeviceSetting {
        var period: String?
        var mode: String?
        var vibrate: Bool?
        var mute: Bool?
        var mute_time: [Any]?
        var ring: String?
        var timezone: Date?
        var roaming: Bool?
        var auto_answer: Bool?
        var save_power: Bool?
        var languages: [String]?
        var language: String?
        var hour24: Bool?
        var auto_time: Bool?
        var dst: Bool?
        var auto_power_onoff: Bool?
        var boot_time: Date?
        var shutdown_time: Date?
        var sos: [String]?
        var school_time: SchoolTime?
        var permissions: [Bool]?
        var reminder: Reminder?
    }
    
    struct Reminder {
        var alarms: [Alarm]?
        var todo:[Todo]?
    }
    
    struct Todo {
        var topic: String?
        var content: String?
        var start: Date?
        var end: Date?
        var repeatCount: Int?
    }
    
    struct Alarm {
        var alarmAt: Date?
        var days: [Int]?
        var active: Bool?
    }
    
    struct SchoolTime {
        var periods: [SchoolTimePeriod]?
        var days: [Int]?
        var active: Bool?
    }
    
    struct SchoolTimePeriod {
        var start: Date?
        var end: Date?
    }
    
    struct DeviceSendNotify {
        var code: Int?
        var value: String?
    }
    
    struct  DevicePower {
        var power: Int?
    }
}

extension MoveApi.Todo: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        topic <- map["topic"]
        content <- map["content"]
        start <- map["start"]
        end <- map["end"]
        repeatCount <- map["repeat"]
    }
    
}

extension MoveApi.Alarm: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        alarmAt <- map["alarm"]
        days <- map["days"]
        active <- map["active"]
    }
}

func ==(lhs: MoveApi.Alarm, rhs: MoveApi.Alarm) -> Bool {
    guard lhs.alarmAt == rhs.alarmAt else {
        return false
    }
    
    guard let lhsDays = lhs.days, let rhsDays = rhs.days else {
        if lhs.days == nil && rhs.days == nil {
            return true
        }
        return false
    }
    
    guard lhsDays == rhsDays else {
        return false
    }
    
    return true
}


extension MoveApi.Reminder: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        alarms <- map["alarms"]
        todo <- map["todo"]
    }
    
}

extension MoveApi.SchoolTime: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        periods <- map["periods"]
        days <- map["days"]
        active <- map["active"]
    }
}

extension MoveApi.SchoolTimePeriod: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        start <- (map["start"], DateIntTransform())
        end <- (map["end"], DateIntTransform())
    }
}

extension MoveApi.DeviceBind: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        bind <- map["bind"]
    }
}

extension MoveApi.DeviceAdd: Mappable {
    init?(map: Map) {
    }
    
    init(sid: String, vcode:String, phone: String, identity: String, nickname: String, number: String, gender: String) {
        self.sid = sid
        self.vcode = vcode
        self.phone = phone
        self.identity = identity
        self.nickName = nickname
        self.number = number
        self.gender = gender
    }
    
    mutating func mapping(map: Map) {
        sid <- map["sid"]
        vcode <- map["vcode"]
        phone <- map["phone"]
        identity <- map["identity"]
        profile <- map["profile"]
        nickName <- map["nickName"]
        number <- map["number"]
        gender <- map["gender"]
        height <- map["height"]
        weight <- map["weight"]
        birthday <- (map["birthday"], DateIntTransform())
    }
}

extension MoveApi.DeviceContactInfo: Mappable {
    init?(map: Map) {
    }
    
    init(phone: String, identity: String) {
        self.phone = phone
        self.identity = identity
    }
    
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        identity <- map["identity"]
        flag <- map["flag"]
    }
}

extension MoveApi.DeviceGetListResp: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        devices <- map["devices"]
    }
}

extension MoveApi.DeviceInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        pid <- map["pid"]
        deviceId <- map["device_id"]
        user <- map["user"]
        property <- map["properties"]
    }
}

extension MoveApi.DeviceUpdateReq: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        device <- map["device"]
    }
}


extension MoveApi.DeviceUpdateInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        user <- map["user"]
    }
}

extension MoveApi.DeviceUser: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        number <- map["number"]
        nickname <- map["nickname"]
        profile <- map["profile"]
        gender <- map["gender"]
        height <- map["height"]
        weight <- map["weight"]
        birthday <- (map["birthday"], DateIntTransform())
    }
}

extension MoveApi.DeviceProperty: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        active <- map["active"]
        bluetooth_address <- map["bluetooth_address"]
        device_model <- map["device_model"]
        firmware_version <- map["firmware_version"]
        ip_address <- map["ip_address"]
        kernel_version <- map["kernel_version"]
        mac_address <- map["mac_address"]
        phone_number <- map["phone_number"]
        languages <- map["languages"]
        power <- map["power"]
    }
}

extension MoveApi.DeviceSetting: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
         period <- map["period"]
         mode <- map["mode"]
         vibrate <- map["vibrate"]
         mute <- map["mute"]
         mute_time <- map["mute_time"]
         ring <- map["ring"]
         timezone <- (map["timezone"], DateTransform())
         roaming <- map["roaming"]
         auto_answer <- map["auto_answer"]
         save_power <- map["save_power"]
         languages <- map["languages"]
         language <- map["language"]
         hour24 <- map["hour24"]
         auto_time <- map["auto_time"]
         dst <- map["dst"]
         auto_power_onoff <- map["auto_power_onoff"]
         boot_time <- (map["boot_time"], DateIntTransform())
         shutdown_time <- (map["shutdown_time"],DateIntTransform())
         sos <- map["sos"]
         school_time <- map["school_time"]
         permissions <- map["permissions"]
         reminder <- map["reminder"]
    }
}

extension MoveApi.DeviceSendNotify: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        code <- map["code"]
        value <- map["value"]
    }
}

extension MoveApi.DevicePower: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        power <- map["power"]
    }
}




