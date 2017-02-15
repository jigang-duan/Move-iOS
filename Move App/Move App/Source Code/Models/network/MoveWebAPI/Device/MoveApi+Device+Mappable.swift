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
    }
    
    struct DeviceAdd {
        var sid: String?
        var vcode: String?
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
        var boot_time: Int64?
        var shutdown_time: Int64?
        var sos: [String]?
        var school_time: Any?
        var permissions: [Any]?
        var reminders: [Any]?
    }
}

extension MoveApi.DeviceAdd: Mappable {
    init?(map: Map) {
    }
    
    init(sid: String, vcode:String, phone: String, identity: String) {
        self.sid=sid
        self.vcode=vcode
        self.phone=phone
        self.identity=MoveApi.DeviceAddIdentity(rawValue: identity)
    }
    
    mutating func mapping(map: Map) {
        sid <- map["sid"]
        vcode <- map["vcode"]
        phone <- map["phone"]
        identity <- map["identity"]
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
         boot_time <- map["boot_time"]
         shutdown_time <- map["shutdown_time"]
         sos <- map["sos"]
         school_time <- map["school_time"]
         permissions <- map["permissions"]
         reminders <- map["reminders"]
    }
}






