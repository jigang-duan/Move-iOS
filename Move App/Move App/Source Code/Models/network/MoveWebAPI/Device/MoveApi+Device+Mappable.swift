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
        var heightUnit: Int?
        var weightUnit: Int?
        var birthday: Date?
    }
    
    struct DeviceContacts {
        var gid: String?
        var contacts: [MoveIM.ImContact]?
    }
    
    struct DeviceContactInfo {
        var phone: String?
        var identity: String?
        var flag: Int?
        var profile: String?
    }
    
    struct DeviceAdmin {
        var uid: String?
    }
    
    struct DeviceFriends {
        var friends: [DeviceFriend]?
    }
    
    struct DeviceFriend {
        var uid: String?
        var nickname: String?
        var profile: String?
        var phone: String?
    }
    
    struct DeviceGetListResp {
        var devices: [DeviceInfo]?
    }
    
    struct DeviceInfo {
        var deviceId: String?
        var pid: Int?
        var uid: String?
        var property: DeviceProperty?
        var settings: DeviceSetting?
        var user: DeviceUser?
    }
    
    struct DeviceInfoResp {
        var device: DeviceInfo?
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
        var heightUnit: Int?
        var weightUnit: Int?
        var birthday: Date?
        var gid: String?
        var online: Bool?
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
    
    
    struct DeviceSetting {
        var period: String?
        var mode: String?
        var vibrate: Bool?
        var mute: Bool?
        var mute_time: [Any]?
        var ring: String?
        var timezone: String?
        var roaming: Bool?
        var auto_positiion: Bool?
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
        var permissions: [Int]?
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
    
    
    struct DeviceVersionCheck {
        var id: String?
        var mode: String?
        var cktp: String?
        var curef: String?
        var cltp: String?
        var type: String?
        var fv: String?
    }
    
    struct DeviceVersionInfo {
        var update_desc: String?
        var encoding_error: String?
        var curef: String?
        var version: Version?
        var firmware: Firmware?
        var spopList: [String]?
    }
    
    struct Version {
        var type: String?
        var fv: String?
        var tv: String?
        var svn: String?
        var releaseInfo: ReleaseInfo?
    }
    
    struct ReleaseInfo {
        var year: String?
        var month: String?
        var day: String?
        var hour: String?
        var minute: String?
        var second: String?
        var timezone: String?
        var publisher: String?
    }
    
    struct Firmware {
        var fwId: String?
        var filesetCount: String?
        var fileset: [VersionFile]?
    }
    
    struct VersionFile {
        var fileName: String?
        var fileId: String?
        var size: String?
        var checkSum: String?
        var fileVersion: String?
        var index: String?
    }
    
    
    struct Timezone {
        var id: String?
        var lng: Double?
        var lat: Double?
        var gmtoffset: Int?
        var countryname: String?
        var timezoneId: String?
    }
    
}

extension MoveApi.Todo: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        topic <- map["topic"]
        content <- map["content"]
        start <- (map["start"],DateIntTransform())
        end <- (map["end"],DateIntTransform())
        repeatCount <- map["repeat"]
    }
    
}

extension MoveApi.Alarm: Mappable {
    init?(map: Map) {
    }
    mutating func mapping(map: Map) {
        alarmAt <- (map["alarm"], DateIntTransform())
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
        heightUnit <- map["height_unit"]
        weightUnit <- map["weight_unit"]
        birthday <- (map["birthday"], DateIntTransform())
    }
}

extension MoveApi.DeviceContacts: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        contacts <- map["contacts"]
        gid <- map["gid"]
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
        profile <- map["profile"]
    }
}

extension MoveApi.DeviceAdmin: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
    }
}

extension MoveApi.DeviceFriends: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        friends <- map["friends"]
    }
}

extension MoveApi.DeviceFriend: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        nickname <- map["nickname"]
        profile <- map["profile"]
        phone <- map["phone"]
    }
}

extension MoveApi.DeviceGetListResp: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        devices <- map["devices"]
    }
}

extension MoveApi.DeviceInfoResp: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        device <- map["device"]
    }
}


extension MoveApi.DeviceInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        pid <- map["pid"]
        deviceId <- map["device_id"]
        uid <- map["uid"]
        property <- map["propertites"]
        settings <- map["settings"]
        user <- map["user"]
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
        heightUnit <- map["height_unit"]
        weightUnit <- map["weight_unit"]
        birthday <- (map["birthday"], DateIntTransform())
        gid <- map["gid"]
        online <- map["online"]
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
        maxgroups <- map["maxgroups"]
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
         timezone <- map["timezone"]
         roaming <- map["roaming"]
         auto_positiion <- map["auto_position"]
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


extension MoveApi.DeviceVersionCheck: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        mode <- map["mode"]
        cktp <- map["cktp"]
        curef <- map["curef"]
        cltp <- map["cltp"]
        type <- map["type"]
        fv <- map["fv"]
    }
}

extension MoveApi.Timezone: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- map["_id"]
        lng <- map["lng"]
        lat <- map["lat"]
        gmtoffset <- map["gmtoffset"]
        countryname <- map["countryname"]
        timezoneId <- map["TimeZoneId"]
    }
}

