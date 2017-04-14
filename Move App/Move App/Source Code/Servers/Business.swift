//
//  Business.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

class Me {
    static let shared = Me()
    
    var user: UserInfo
    var currDeviceID: String? {
        get{
            return DeviceManager.shared.currentDevice?.deviceId
        }
    }
    
    init() {
        self.user = UserInfo.shared
    }
    
}


class MessageManager {
}

protocol Authority {
}

struct KidProfile {
    var kidId: String
    var phone: String?
    var nickName: String?
    var headPortrait: String?
    var gender: Gender?
    var height: Int?
    var weight: Double?
    var birthday: Date?
}

class KidSate {
    
    struct LocationInfo {
        var location: CLLocationCoordinate2D?
        var address: String?
        var accuracy: CLLocationDistance?
        var time: Date?
    }
    
    struct ElectronicFencea {
        var ids: String?
        var name: String?
        var radius: Double?
        var active: Bool?
        var location: locatio?
    }
    
    struct locatio {
        var location: CLLocationCoordinate2D?
        var address: String?
    }
    
    var fences: [ElectronicFencea]?
    
    
    struct SOSLbsModel {
        
        struct BTS {
            var mcc: Int?
            var mnc: Int?
            var lac: Int?
            var cellId: Int?
            var signal: Int?
        }
        
        struct WiFi {
            var mac: String?
            var ssid: String?
            var signal: Int?
        }
        
        var imei: String?
        var utc: Date?
        var location: LocationInfo?
        var bts: [BTS]?
        var wifi: [WiFi]?
    }
    
}

class KidLocationManager {
}

struct KidSetting {
    
    struct SchoolTime {
        var amStartPeriod: Date?
        var amEndPeriod: Date?
        var pmStartPeriod: Date?
        var pmEndPeriod: Date?
        var days: [Bool] = []
        var active: Bool?
    }
    
    struct Reminder {
        struct Alarm {
            var alarmAt: Date?
            var day: [Bool] = []
            var active: Bool?
        }
        
        struct ToDo {
            var topic: String?
            var content: String?
            var start: Date?
            var end: Date?
            var repeatCount: Int?
        }
        
        var alarms: [Alarm] = []
        var todo: [ToDo] = []
    }
    
    var reminders: [Reminder]?
    var schoolTime: SchoolTime?
    
}

struct WatchProfile {
    var devcieId: String
}

struct WatchState {
    var power: Int
}

struct WatchSetting {
    var id: String
    var period: String?
    var positioningMode: PositioningMode?
    var vibrateEnable: Bool?
    var muteEnable: Bool?
    var muteTimes: [MuteTime]?
    var roamingEnable: Bool?
    var autoAnswerEnable: Bool?
    var savePowerEnable: Bool?
    var languages: [String]?
    var language: String?
    var hour24Enable: Bool?
    var autoTimeEnable: Bool?
    var dstEnable: Bool?
    var autoPowerOn: Bool?
    var bootTime: Int?
    var shutdowTime: Int?
    var permissions: [Bool]?
}

struct MuteTime {
}


enum Gender {
    case male
    case female
}

enum PositioningMode {
    case accurate
    case normal
    case savepower
}

enum Relation {
    case mother
    case father
    case grandmaF
    case grandPaF
    case grandmaM
    case grandpaM
    case uncle
    case aunty
    case sister
    case brother
    case other(value: String)
}

extension Relation {
    
    init?(input: String) {
        switch input {
        case "1":
            self = .mother
        case "2":
            self = .father
        case "3":
            self = .grandmaF
        case "4":
            self = .grandPaF
        case "5":
            self = .grandmaM
        case "6":
            self = .grandpaM
        case "7":
            self = .uncle
        case "8":
            self = .aunty
        case "9":
            self = .sister
        case "10":
            self = .brother
        default:
            self = .other(value: input)
        }
    }
}

extension Relation: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .mother:
            return "Mother"
        case .father:
            return "Father"
        case .grandmaF:
            return "GrandmaF"
        case .grandPaF:
            return "GrandPaF"
        case .grandmaM:
            return "GrandmaM"
        case .grandpaM:
            return "GrandpaM"
        case .uncle:
            return "Uncle"
        case .aunty:
            return "Aunty"
        case .sister:
            return "Sister"
        case .brother:
            return "Brother"
        case . other(let value):
            return value
        }
    }
    
    var identity: String {
        switch self {
        case .mother:
            return "1"
        case .father:
            return "2"
        case .grandmaF:
            return "3"
        case .grandPaF:
            return "4"
        case .grandmaM:
            return "5"
        case .grandpaM:
            return "6"
        case .uncle:
            return "7"
        case .aunty:
            return "8"
        case .sister:
            return "9"
        case .brother:
            return "10"
        case .other(let value):
            return otherIdentity(value)
        }
    }
    
    private func otherIdentity(_ value: String) -> String {
        switch value {
        case "Mother":
            return "1"
        case "Father":
            return "2"
        case "GrandmaF":
            return "3"
        case "GrandPaF":
            return "4"
        case "GrandmaM":
            return "5"
        case "GrandpaM":
            return "6"
        case "Uncle":
            return "7"
        case "Aunty":
            return "8"
        case "Sister":
            return "9"
        case "Brother":
            return "10"
        default:
            return value
        }
    }
}

extension KidSate.SOSLbsModel {
    
    init?(aURL: URL) {
        guard
            let queryString = aURL.queryParameters,
            let imei = queryString["i"] else {
                return nil
        }
        self.init()
        self.imei = imei
        self.location =  KidSate.LocationInfo(ls: queryString["l"] ?? "")
        
        if let utcString = queryString["t"],
            let interval = TimeInterval(utcString) {
            self.utc = Date(timeIntervalSince1970: interval)
            self.location?.time = self.utc
        }
        if let btsString = queryString["c"] {
            self.bts = KidSate.SOSLbsModel.BTS.queryParameters(str: btsString)
        }
        if let wifiString = queryString["w"] {
            self.wifi = KidSate.SOSLbsModel.WiFi.queryParameters(str: wifiString)
        }
        
    }
    
    init?(url: URL) {
        guard
            let queryString = url.urlParameters,
            let imei = queryString["i"] as? String else {
                return nil
        }
        self.init()
        self.imei = imei
        self.location =  KidSate.LocationInfo(ls: (queryString["l"] as? String) ?? "")
        
        if let utcString = queryString["t"] as? String,
            let interval = TimeInterval(utcString) {
            self.utc = Date(timeIntervalSince1970: interval)
            self.location?.time = self.utc
        }
        
        self.bts = (queryString["c"] as? [String])?.flatMap({ KidSate.SOSLbsModel.BTS(cs: $0) })
        self.wifi = (queryString["w"] as? [String])?.flatMap({ KidSate.SOSLbsModel.WiFi(ws: $0) })
    }
    
}

fileprivate extension KidSate.LocationInfo {
    
    init?(ls: String) {
        let components = ls.components(separatedBy: ",")
        guard components.count >= 2 else {
            return nil
        }
        self.init()
        if
            let lat = CLLocationDegrees(components[0]),
            let lng = CLLocationDegrees(components[1]) {
            self.location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }
}

fileprivate extension KidSate.SOSLbsModel.BTS {
    init?(cs: String) {
        self.init(components: cs.components(separatedBy: ",").map({ Int($0) }))
    }
    
    init?(components: [Int?]) {
        guard components.count >= 5 else {
            return nil
        }
        
        self.init()
        self.mcc = components[0]
        self.mnc = components[1]
        self.lac = components[2]
        self.cellId = components[3]
        self.signal = components[4]
    }
    
    static func queryParameters(str: String) -> [KidSate.SOSLbsModel.BTS] {
        return str.components(separatedBy: "],[").map({  $0.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "") }).flatMap({ KidSate.SOSLbsModel.BTS(cs: $0) })
    }
}

fileprivate extension KidSate.SOSLbsModel.WiFi {
    init?(ws: String) {
        let components = ws.components(separatedBy: ",")
        guard components.count >= 3 else {
            return nil
        }
        self.init()
        self.mac = components[0]
        self.ssid = components[1]
        self.signal = Int(components[2])
    }
    
    static func queryParameters(str: String) -> [KidSate.SOSLbsModel.WiFi] {
        return str.components(separatedBy: "],[").map({  $0.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "") }).flatMap({ KidSate.SOSLbsModel.WiFi(ws: $0) })
    }
}


