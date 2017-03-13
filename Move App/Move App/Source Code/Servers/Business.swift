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
    
    func transformToString() -> String{
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
    
    static func transformToEnum(input: Int) -> Relation{
        switch input {
        case 1:
            return Relation.mother
        case 2:
            return Relation.father
        case 3:
            return Relation.grandmaF
        case 4:
            return Relation.grandPaF
        case 5:
            return Relation.grandmaM
        case 6:
            return Relation.grandpaM
        case 7:
            return Relation.uncle
        case 8:
            return Relation.aunty
        case 9:
            return Relation.sister
        case 10:
            return Relation.brother
        default:
            return Relation.other(value: "Other")
        }
    }
}



