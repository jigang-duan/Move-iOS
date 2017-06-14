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
    
    enum LocationType: Int {
        case gps = 0x001
        case lbs = 0x010
        case wifi = 0x100
        case sos = 0x8000
    }
    
    struct LocationTypeSet {
        let set: Set<KidSate.LocationType>
        let rawValue: Int
        
        init(rawValue: Int) {
            var typeSet = Set<KidSate.LocationType>()
            self.rawValue = rawValue
            if (rawValue & KidSate.LocationType.gps.rawValue) != 0 {
                typeSet.insert(.gps)
            }
            if (rawValue & KidSate.LocationType.lbs.rawValue) != 0 {
                typeSet.insert(.lbs)
            }
            if (rawValue & KidSate.LocationType.wifi.rawValue) != 0 {
                typeSet.insert(.wifi)
            }
            if (rawValue & KidSate.LocationType.sos.rawValue) != 0 {
                typeSet.insert(.sos)
            }
            self.set = typeSet
        }
    }
    
    
    struct LocationInfo {
        var location: CLLocationCoordinate2D?
        var address: String?
        var accuracy: CLLocationDistance?
        var time: Date?
        var type: LocationTypeSet?
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

extension KidSate.LocationType: CustomStringConvertible {
    var description: String {
        switch self {
        case .gps:
            return "GPS"
        case .lbs:
            return "LBS"
        case .wifi:
            return "Wifi"
//        case .gps_lbs:
//            return "GPS+LBS"
//        case .gps_wifi:
//            return "GPS+WiFi"
//        case .lbs_wifi:
//            return "LBS+WiFi"
        case .sos:
            return "SOS"
        }
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
    case grandpa
    case grandma
    case uncle
    case aunty
    case brother
    case sister
    case other(value: String)
}

//func ==(lhs: Relation, rhs: Relation) -> Bool {
//    switch (lhs, rhs) {
//        case (.mother, .mother): return true
//        case (.father, .father): return true
//        case (.grandpa, .grandpa): return true
//        case (.grandma, .grandma): return true
//        case (.uncle, .uncle): return true
//        case (.aunty, .aunty): return true
//        case (.brother, .brother): return true
//        case (.sister, .sister): return true
//        case (.other(let a), .other(let b)) where a == b: return true
//        default: return false
//    }
//}


extension Relation {
    
    init?(input: String) {
        switch input {
        case "1":
            self = .mother
        case "2":
            self = .father
        case "3":
            self = .grandpa
        case "4":
            self = .grandma
        case "5":
            self = .uncle
        case "6":
            self = .aunty
        case "7":
            self = .brother
        case "8":
            self = .sister
        default:
            self = .other(value: input)
        }
    }
}

extension Relation: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .mother:
            return  R.string.localizable.id_mother()
        case .father:
            return R.string.localizable.id_father()
        case .grandpa:
            return R.string.localizable.id_grandpa()
        case .grandma:
            return R.string.localizable.id_grandma()
        case .uncle:
            return R.string.localizable.id_uncle()
        case .aunty:
            return R.string.localizable.id_aunt()
        case .sister:
            return R.string.localizable.id_sister()
        case .brother:
            return R.string.localizable.id_brother()
        case .other(let value):
            return value
        }
    }
    
    var identity: String {
        switch self {
        case .mother:
            return "1"
        case .father:
            return "2"
        case .grandpa:
            return "3"
        case .grandma:
            return "4"
        case .uncle:
            return "5"
        case .aunty:
            return "6"
        case .brother:
            return "7"
        case .sister:
            return "8"
        case .other(let value):
            return value
        }
    }
    
//    private func otherIdentity(_ value: String) -> String {
//        switch value {
//        case "Mother":
//            return "1"
//        case "Father":
//            return "2"
//        case "Grandpa":
//            return "3"
//        case "Grandma":
//            return "4"
//        case "Uncle":
//            return "5"
//        case "Aunty":
//            return "6"
//        case "Brother":
//            return "7"
//        case "Sister":
//            return "8"
//        default:
//            return value
//        }
//    }
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
        self.ssid = components[2]
        self.signal = Int(components[1])
    }
    
    static func queryParameters(str: String) -> [KidSate.SOSLbsModel.WiFi] {
        return str.components(separatedBy: "],[").map({  $0.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "") }).flatMap({ KidSate.SOSLbsModel.WiFi(ws: $0) })
    }
}


