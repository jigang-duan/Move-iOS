//
//  DeviceList.swift
//  Move App
//
//  Created by lx on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift
//设备列表
class DeviceList: Object {
    var devicelist = List<DeviceEntity>()
}
//设备信息
class DeviceEntity: Object {
    dynamic var device_id : String? = nil
    dynamic var number: String? = nil
    dynamic var nickname: String? = nil
    dynamic var profile: String? = nil
    dynamic var gender: String? = nil
    dynamic var height = 0
    dynamic var birthday : Int64 = 0
    override static func primaryKey() -> String? {
        return "device_id"
    }
}
//设备配置信息

class DeviceSettingsEntity: Object {
    dynamic var device_id : String? = nil
    dynamic var period = 60
    dynamic var mode: String? = nil
    dynamic var vibrate :Bool = false
    dynamic var mute: Bool = false
    var mute_time = List<MuteTimeEntity>()
    dynamic var ring : String? = nil
    dynamic var timezone  = 0
    dynamic var roaming :Bool = false
    dynamic var auto_answer :Bool = false
    dynamic var save_power :Bool = false
    var languages = List<LanguagesEntity>()
    dynamic var language : String? = nil
    dynamic var hour24 :Bool = false
    dynamic var auto_time :Bool = false
    dynamic var dst :Bool = false
    dynamic var auto_power_onoff :Bool = false
    dynamic var shutdown_time = 0
    var sos = List<SosInfoEntity>()
    var school_time = List<SchoolTimeEntity>()
    var reminders = List<RemindersEntity>()
    var permissions = List<PermissionsEntity>()
}
class LanguagesEntity: Object {
    dynamic var languages: String? = nil
}
class PermissionsEntity: Object {
    dynamic var permissions: Int = 0
}
class SosInfoEntity: Object {
    dynamic var sos: String? = nil
}

class MuteTimeEntity: Object {
    dynamic var enable: Bool = false
    dynamic var start: Int64 = 0
    dynamic var end: Int64 = 0
}
class SchoolTimeEntity: Object {
    var periods = List<PeriodsEntity>()
    dynamic var days: String? = nil
}
class PeriodsEntity: Object {
    dynamic var start: Int64 = 0
    dynamic var end: Int64 = 0
}
class RemindersEntity: Object {
    var periods = List<RemindersTodoEntity>()
    dynamic var alarm: Int64 = 0
}
class RemindersTodoEntity: Object {
    dynamic var alarm: Int64 = 0
    var todo = List<TodoEntity>()
}
class TodoEntity: Object {
    dynamic var topic: String? = nil
    dynamic var content: String? = nil
    dynamic var start: Int64 = 0
    dynamic var end: Int64 = 0
}
//设备电子围栏
class FenceList: Object {
    dynamic var device_id : String? = nil
    var fencelist = List<FenceEntity>()
}

class FenceEntity: Object {
    dynamic var name: String? = nil
    var location = List<LocationEntity>()
    dynamic var radius: Int64 = 0
    dynamic var active: Bool = false
}
class LocationEntity: Object {
    dynamic var lat: Double = 0.000000
    dynamic var lng: Double = 0.000000
    dynamic var addr: String? = nil
}
