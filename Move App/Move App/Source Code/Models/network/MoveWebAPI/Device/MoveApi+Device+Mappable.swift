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
    
    enum DeviceAddIdentity: String{
        case unowner = ""
        case mother = "Mother"
        case father = "Father"
        case grandmaF = "GrandmaF"
        case grandPaF = "GrandPaF"
        case grandmaM = "GrandmaM"
        case grandpaM = "GrandpaM"
        case uncle = "Uncle"
        case aunty = "Aunty"
        case sister = "Sister"
        case brother = "Brother"
        case other = "Other"
        
        static func transform(input: Int) -> DeviceAddIdentity{
            switch input {
            case 0:
                return DeviceAddIdentity.unowner
            case 1:
                return DeviceAddIdentity.mother
            case 2:
                return DeviceAddIdentity.father
            case 3:
                return DeviceAddIdentity.grandmaF
            case 4:
                return DeviceAddIdentity.grandPaF
            case 5:
                return DeviceAddIdentity.grandmaM
            case 6:
                return DeviceAddIdentity.grandpaM
            case 7:
                return DeviceAddIdentity.uncle
            case 8:
                return DeviceAddIdentity.aunty
            case 9:
                return DeviceAddIdentity.sister
            case 10:
                return DeviceAddIdentity.brother
            default:
                return DeviceAddIdentity.other
            }
        }
    }
    
    struct DeviceAdd {
        var sid: String?
        var vcode: String?
        var phone: String?
        var identity: DeviceAddIdentity?
        var profile: String?
        var nickName: String?
        var number: String?
        var gender: String?
        var height: Int?
        var weight: Int?
        var birthday: Date?
    }
    
    struct DeviceJoinInfo {
        var phone: String?
        var identity: DeviceAddIdentity?
        var profile: String?
    }
    
    
    struct DeviceGetListResp {
        var devices: [DeviceInfo]?
    }
    
    struct DeviceInfo {
        var device_id: String?
        var number: String?
        var name: String?
        var profile: String?
        var gender: String?
        var height: Int?
        var birthday: Date?
    }
    
    struct DeviceSetting {
        var period: String?
        var mode: String?
        var vibrate: Bool?
        var mute: Bool?
        var mute_time: [Any]?
        var ring: String?
        var timezone: Int?
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
        start <- (map["start"], DateTransform())
        end <- (map["end"], DateTransform())
    }
}

extension MoveApi.DeviceAdd: Mappable {
    init?(map: Map) {
    }
    
    init(sid: String, vcode:String, phone: String, identity: MoveApi.DeviceAddIdentity, nickname: String, number: String, gender: String) {
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
        identity <- (map["identity"], EnumTransform())
        profile <- map["profile"]
        nickName <- map["nickName"]
        number <- map["number"]
        gender <- map["gender"]
        height <- map["height"]
        weight <- map["weight"]
        birthday <- (map["birthday"], DateTransform())
    }
}

extension MoveApi.DeviceJoinInfo: Mappable {
    init?(map: Map) {
    }
    
    init(phone: String, identity: MoveApi.DeviceAddIdentity) {
        self.phone = phone
        self.identity = identity
    }
    
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        identity <- (map["identity"], EnumTransform())
        profile <- map["profile"]
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
        device_id <- map["device_id"]
        number <- map["number"]
        name <- map["name"]
        profile <- map["profile"]
        gender <- map["gender"]
        height <- map["height"]
        birthday <- (map["birthday"], DateTransform())
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
         auto_answer <- map["auto_answer"]
         save_power <- map["save_power"]
         languages <- map["languages"]
         language <- map["language"]
         hour24 <- map["hour24"]
         auto_time <- map["auto_time"]
         dst <- map["dst"]
         auto_power_onoff <- map["auto_power_onoff"]
         boot_time <- (map["boot_time"], DateTransform())
         shutdown_time <- (map["shutdown_time"],DateTransform())
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




