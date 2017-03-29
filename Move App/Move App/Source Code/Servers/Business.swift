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
    var currDeviceID: String?
    
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
        var addr: String?
        
    }
    
    var fences: [ElectronicFencea]?
    
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
            var active : Bool?
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
}



