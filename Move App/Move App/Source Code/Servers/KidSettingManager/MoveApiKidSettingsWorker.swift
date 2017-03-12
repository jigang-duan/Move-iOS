//
//  MoveApiKidSettingsWorker.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class MoveApiKidSettingsWorker: KidSettingsWorkerProtocl {
    
    func fetchSchoolTime(id: String) -> Observable<KidSetting.SchoolTime> {
        return MoveApi.Device
            .getSetting(deviceId: id)
            .map(wrappingSchoolTime)
    }
    
    func updateSchoolTime(id: String, _ schoolTime: KidSetting.SchoolTime) -> Observable<Bool> {
        return MoveApi.Device
            .getSetting(deviceId: id)
            .flatMapFirst { (item) -> Observable<MoveApi.ApiError> in
                var setting = item
                setting.school_time = self.unwrapping(schoolTime: schoolTime)
                return MoveApi.Device.setting(deviceId: id, settingInfo: setting)
            }
            .map { $0.id == 0 }
        
    }
    
    func updateAlarm(deviceId: String, old : KidSetting.Reminder.Alarm, new: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        return MoveApi.Device
            .getSetting(deviceId: deviceId)
            .flatMapLatest({ settings -> Observable<MoveApi.ApiError> in
                var _setting = settings
                let oldAlarm = self.unwrappingAlarm(old)
                let newAlarm = self.unwrappingAlarm(new)
                if let alarms = _setting.reminder?.alarms {
                    for (index, alarm) in alarms.enumerated() {
                        if alarm == oldAlarm {
                            _setting.reminder?.alarms?.remove(at: index)
                            _setting.reminder?.alarms?.insert(newAlarm, at: index)
                            break
                        }
                    }
                }
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    
    func creadAlarm(deviceId: String, _ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        return MoveApi.Device
            .getSetting(deviceId: deviceId)
            .flatMapLatest({ settings -> Observable<MoveApi.ApiError> in
                var _setting = settings
                if _setting.reminder == nil {
                    _setting.reminder = MoveApi.Reminder()
                }
                if _setting.reminder?.alarms == nil {
                    _setting.reminder?.alarms = []
                }
                _setting.reminder?.alarms?.append(self.unwrappingAlarm(alarm))
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    
//    func updateTodoList(deviceId: String, old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool>
//    {
//       
//    }
    
    func creadTodoLis(deviceId: String, _ todolist: KidSetting.Reminder.ToDo) -> Observable<Bool>{
        return MoveApi.Device
            .getSetting(deviceId: deviceId)
            .flatMapLatest({ settings -> Observable<MoveApi.ApiError> in
                var _setting = settings
                if _setting.reminder == nil {
                    _setting.reminder = MoveApi.Reminder()
                }
                if _setting.reminder?.todo == nil {
                    _setting.reminder?.todo = []
                }
                _setting.reminder?.todo?.append(self.unwrapping(todo: todolist))
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
   
    func fetchreminder(id: String) -> Observable<KidSetting.Reminder>{
        return MoveApi.Device
            .getSetting(deviceId: id)
            .map(wrappingReminder)
    }
    
    
}

class MoveApiWatchSettingsWorker: WatchSettingWorkerProtocl {
    
    func fetchLanguages(id: String) ->  Observable<[String]> {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.languages ?? [] })
    }
    
    func fetchLanguage(id: String) ->  Observable<String> {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({
                $0.language ?? ""
            })
    }
    
    func updateLanguage(id: String, _ language: String) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.language = language
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    
    
    func fetchshutTime(id: String) -> Observable<Date>{
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.shutdown_time ?? DateUtility.zone16hour() })
    }
    func fetchbootTime(id: String) -> Observable<Date>{
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.boot_time ?? DateUtility.zone7hour() })
    }
    func fetchoAutopoweronoff(id: String) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.auto_power_onoff ?? false })
    }
    
    func updateTime(id: String, bootTime: Date, shuntTime: Date, Autopoweronoff: Bool) -> Observable<Bool>{
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.boot_time = bootTime
                _setting.shutdown_time = shuntTime
                _setting.auto_power_onoff = Autopoweronoff
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    func fetchUsePermission(id: String) -> Observable<[Bool]>{
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.permissions ?? [false,false,false,false,false] })
    
    }
    func upUsePermission(id: String, btns: [Bool]) -> Observable<Bool>{
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.permissions = btns
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    
    func fetchHoursFormat(id: String) -> Observable<Bool>
    {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.hour24 ?? false })
    }
    
    func fetchGetTimeAuto(id: String) -> Observable<Bool>
    {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.auto_time ?? false })
    }
    func fetchTimezone(id:String) -> Observable<Date> //发服务器为int
    {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.timezone ?? DateUtility.zone7hour() })
    }
    func fetchSummerTime(id: String) -> Observable<Bool>
    {
        return MoveApi.Device.getSetting(deviceId: id)
            .map({ $0.dst ?? false })
    }
    func updateTimezones(id: String, hourformat: Bool, autotime: Bool,Timezone: Date, summertime: Bool) -> Observable<Bool>
    {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.dst = summertime
                _setting.auto_time = autotime
                _setting.hour24 = hourformat
                _setting.timezone = Timezone
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map({ $0.id == 0 })
    }
    
    
    
}

extension MoveApiKidSettingsWorker {
    
    func unwrapping(todo: KidSetting.Reminder.ToDo) -> MoveApi.Todo {
        return MoveApi.Todo(topic: todo.topic, content: todo.content, start: todo.start, end: todo.end, repeatCount: todo.repeatCount)
    }

    
    
    func unwrappingAlarm(_ alarm: KidSetting.Reminder.Alarm) -> MoveApi.Alarm {
        var days: [Int] = []
        for i in 1 ... 7 {
            if alarm.day[i - 1] {
                days.append(i)
            }
        }
        return MoveApi.Alarm(alarmAt: alarm.alarmAt, days: days, active: true)
    }
    
     func unwrapping(schoolTime: KidSetting.SchoolTime) -> MoveApi.SchoolTime {
        var wrap = MoveApi.SchoolTime()
        wrap.periods = [MoveApi.SchoolTimePeriod(start: schoolTime.amStartPeriod, end: schoolTime.amEndPeriod),
                        MoveApi.SchoolTimePeriod(start: schoolTime.pmStartPeriod, end: schoolTime.pmEndPeriod)]
        var days: [Int] = []
        for i in 1 ... 7 {
            if schoolTime.days[i - 1] {
                days.append(i)
            }
        }
        wrap.days = days
        wrap.active = schoolTime.active
        return wrap
    }
    
     func wrappingSchoolTime(_ settings: MoveApi.DeviceSetting) -> KidSetting.SchoolTime {
        return self.wrapping(schoolTime: settings.school_time)
    }
    
    func wrappingReminder(_ settings: MoveApi.DeviceSetting) -> KidSetting.Reminder {
        return self.wrappingr(reminder: settings.reminder)
    }
    
     func wrapping(schoolTime: MoveApi.SchoolTime?) -> KidSetting.SchoolTime {
        guard let time = schoolTime else {
            return KidSetting.SchoolTime(
                amStartPeriod: DateUtility.zone7hour(),
                amEndPeriod: DateUtility.zone12hour(),
                pmStartPeriod: DateUtility.zone14hour(),
                pmEndPeriod: DateUtility.zone16hour(),
                days: [false, false, false, false, false, false, false],
                active: false )
            
        }
        
        var days = [false, false, false, false, false, false, false]
        for i in 1 ... 7 {
            if let _days = time.days, _days.contains(i) {
                days[i - 1] = true
            }
        }
        return KidSetting.SchoolTime(
            amStartPeriod: time.periods?[0].start ?? DateUtility.zone7hour(),
            amEndPeriod: time.periods?[0].end ?? DateUtility.zone12hour(),
            pmStartPeriod: time.periods?[1].start ?? DateUtility.zone14hour(),
            pmEndPeriod: time.periods?[1].end ?? DateUtility.zone16hour(),
            days: days,active: time.active ?? false)
        
        
    }
   
 
    func wrappingr(reminder: MoveApi.Reminder?) -> KidSetting.Reminder {
        let todos = reminder?.todo?.flatMap({ KidSetting.Reminder.ToDo(topic: $0.topic, content: $0.content, start: $0.start, end: $0.end, repeatCount: $0.repeatCount) })
        
        let alarms = reminder?.alarms?.flatMap({ KidSetting.Reminder.Alarm(alarmAt: $0.alarmAt, day: daysToBool(timeDays: $0.days) ) })
        
        return KidSetting.Reminder(alarms: alarms ?? [], todo: todos ?? [])
    }
    
    private func daysToBool(timeDays: [Int]?) -> [Bool] {
        var days = [false, false, false, false, false, false, false]
        for i in 1 ... 7 {
            if let _days = timeDays, _days.contains(i) {
                days[i - 1] = true
            }
        }
        return days
    }
    
}



