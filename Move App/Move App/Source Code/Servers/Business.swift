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
    
    var roles: [Role] = []
    var user: UserInfo
    
    init() {
        self.user = UserInfo.shared
    }
}

protocol Role {
    var type: RoleType {get}
}

enum RoleType {
    case guardian
}

class Grardian: Role {
    private(set) var type: RoleType = .guardian
    
    var kids: [(Relation, Kid)] = []
    
    var message: MessageManager?
    var authority: Authority?
}

class Kid {
    var id: String
    
    var relations: [Relation] = []
    
    var profile: KidProfile
    var state: KidSate?
    var settings: KidSetting?
    
    var watch: KidWatch?
    
    init (id: String, profile: KidProfile) {
        self.id = id
        self.profile = profile
    }
}

class KidWatch {
    var id: String
    
    var profile: WatchProfile
    var state: WatchState?
    var settings: WatchSetting?
    
    init(id: String, profile: WatchProfile) {
        self.id = id
        self.profile = profile
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
    var locaationManager: KidLocationManager
    
    init() {
        locaationManager = KidLocationManager()
    }
}

class KidLocationManager {
}

struct KidSetting {
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
    var reminders: [Reminder]?
}

struct MuteTime {
}

struct Reminder {
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

enum Relation: Int {
    case unowner = 0
    case mother = 1
    case father = 2
    case grandMaF = 3
    case grandPaF = 4
    case grandmaM = 5
    case grandpaM = 6
    case uncle = 7
    case aunty = 8
    case sister = 9
    case brother = 10
    case other
}
