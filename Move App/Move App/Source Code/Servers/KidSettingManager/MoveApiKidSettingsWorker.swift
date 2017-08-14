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
        return MoveApi.Device.fetchSetting(deviceId: id).map(wrappingSchoolTime)
    }
    
    func fetchreminder(id: String) -> Observable<KidSetting.Reminder>{
        return MoveApi.Device.fetchSetting(deviceId: id).map(wrappingReminder)
    }
    
    func updateSchoolTime(id: String, _ schoolTime: KidSetting.SchoolTime) -> Observable<Bool> {
        return MoveApi.Device
            .getSetting(deviceId: id)
            .flatMapFirst { (item) -> Observable<MoveApi.ApiError> in
                var setting = item
                setting.school_time = self.unwrapping(schoolTime: schoolTime)
                return MoveApi.Device.setting(deviceId: id, settingInfo: setting)
            }
            .map(errorTransform)
            .catchError(errorHandle)
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
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updateTodoList(deviceId: String, old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool> {
        return MoveApi.Device
            .getSetting(deviceId: deviceId)
            .flatMapLatest({ settings -> Observable<MoveApi.ApiError> in
                var _setting = settings
                let oldTodo = self.unwrapping(todo: old)
                let newTodo = self.unwrapping(todo: new)
                if let todos = _setting.reminder?.todo {
                    for (index, todo) in todos.enumerated() {
                        if oldTodo.content == todo.content {
                            if oldTodo.topic == todo.topic{
                            _setting.reminder?.todo?.remove(at: index)
                            _setting.reminder?.todo?.insert(newTodo, at: index)
                            break
                            }
                        }
                    }
                }
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }

    
    func addAlarm(deviceId: String, _ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool> {
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
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    
    func addTodo(deviceId: String, _ todo: KidSetting.Reminder.ToDo) -> Observable<Bool>{
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
                _setting.reminder?.todo?.append(self.unwrapping(todo: todo))
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updateReminder(id: String, _ reminder: KidSetting.Reminder) -> Observable<Bool>{
        return MoveApi.Device
            .getSetting(deviceId: id)
            .flatMapFirst { (item) -> Observable<MoveApi.ApiError> in
                var setting = item
                setting.reminder = self.unwrappingr(remind: reminder)
                return MoveApi.Device.setting(deviceId: id, settingInfo: setting)
            }
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
}

extension MoveApiKidSettingsWorker {
    
    func unwrapping(todo: KidSetting.Reminder.ToDo) -> MoveApi.Todo {
        return MoveApi.Todo(topic: todo.topic, content: todo.content, start: todo.start, end: todo.end, repeatCount: todo.repeatCount)
    }
    
    func unwrappingAlarm(_ alarm: KidSetting.Reminder.Alarm) -> MoveApi.Alarm {
        var days: [Int] = []
        for i in 0 ... 6 {
            if alarm.day[i] {
                days.append(i)
            }
        }
        
        return MoveApi.Alarm(alarmAt: alarm.alarmAt, days: days, active: alarm.active)
    }
    
     func unwrapping(schoolTime: KidSetting.SchoolTime) -> MoveApi.SchoolTime {
        var wrap = MoveApi.SchoolTime()
        wrap.periods = [MoveApi.SchoolTimePeriod(start: schoolTime.amStartPeriod, end: schoolTime.amEndPeriod),
                        MoveApi.SchoolTimePeriod(start: schoolTime.pmStartPeriod, end: schoolTime.pmEndPeriod)]
        var days: [Int] = []
        for i in 0 ... 6 {
            if schoolTime.days[i] {
                days.append(i)
            }
        }
        wrap.days = days
        wrap.active = schoolTime.active
        return wrap
    }
    
   
    
    func unwrappingr(remind: KidSetting.Reminder) -> MoveApi.Reminder {
        return MoveApi.Reminder(
            alarms: remind.alarms.map { MoveApi.Alarm(alarmAt: $0.alarmAt, days: days(every: $0.day), active: $0.active) },
            todo: remind.todo.map { MoveApi.Todo(topic: $0.topic, content: $0.content, start: $0.start, end: $0.end, repeatCount: $0.repeatCount) }
        )
    }
    
    private func days(every: [Bool]) -> [Int] {
        var days: [Int] = []
        for i in 0 ... 6 {
            if every[i] {
                days.append(i)
            }
        }
        return days
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
        for i in 0 ... 6 {
            if let _days = time.days, _days.contains(i) {
                days[i] = true
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
    
        let alarms = reminder?.alarms?.flatMap({ KidSetting.Reminder.Alarm(alarmAt: $0.alarmAt, day: daysToBool(timeDays: $0.days), active: $0.active ) })
        
        return KidSetting.Reminder(alarms: alarms ?? [], todo: todos ?? [])
    }
    
    
    private func daysToBool(timeDays: [Int]?) -> [Bool] {
        var days = [false, false, false, false, false, false, false]
        for i in 0 ... 6 {
            if let _days = timeDays, _days.contains(i) {
                days[i] = true
            }
        }
        return days
    }
    
}

