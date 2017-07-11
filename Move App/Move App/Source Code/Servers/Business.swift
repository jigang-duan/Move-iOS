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
    
    struct ElectronicFence {
        var ids: String?
        var name: String?
        var radius: Double?
        var active: Bool?
        var location: Location?
    }
    
    struct Location {
        var location: CLLocationCoordinate2D?
        var address: String?
    }
    
    var fences: [ElectronicFence]?
    
    
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
    
    var image: UIImage? {
        switch self {
        case .mother:
            return R.image.relationship_ic_mun()
        case .father:
            return R.image.relationship_ic_dad()
        case .grandpa:
            return R.image.relationship_ic_grandpa()
        case .grandma:
            return R.image.relationship_ic_grandma()
        case .uncle:
            return R.image.relationship_ic_uncle()
        case .aunty:
            return R.image.relationship_ic_aunt()
        case .brother:
            return R.image.relationship_ic_brother()
        case .sister:
            return R.image.relationship_ic_sister()
        case .other:
            return R.image.relationship_ic_other()
        }
    }
    
    var imageName: String {
        switch self {
        case .mother:
            return "relationship_ic_mun"
        case .father:
            return "relationship_ic_dad"
        case .grandpa:
            return "relationship_ic_grandpa"
        case .grandma:
            return "relationship_ic_grandma"
        case .uncle:
            return "relationship_ic_uncle"
        case .aunty:
            return "relationship_ic_aunt"
        case .brother:
            return "relationship_ic_brother"
        case .sister:
            return "relationship_ic_sister"
        case .other:
            return "relationship_ic_other"
        }
    }
}
