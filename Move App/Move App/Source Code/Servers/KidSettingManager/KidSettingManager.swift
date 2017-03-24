//
//  KidSettingManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

/// User KidSettings Protocl
protocol KidSettingsWorkerProtocl {
    
    func fetchSchoolTime(id: String) -> Observable<KidSetting.SchoolTime>
    func updateSchoolTime(id: String, _ schoolTime: KidSetting.SchoolTime) -> Observable<Bool>
    
    func updateAlarm(deviceId: String, old : KidSetting.Reminder.Alarm, new: KidSetting.Reminder.Alarm) -> Observable<Bool>
    func creadAlarm(deviceId: String, _ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool>
    
//    func updateTodoList(deviceId: String, old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool>
    func creadTodoLis(deviceId: String, _ todolist: KidSetting.Reminder.ToDo) -> Observable<Bool>
    
    
    func fetchreminder(id: String) -> Observable<KidSetting.Reminder>
    func updateReminder(id: String, _ reminder: KidSetting.Reminder) -> Observable<Bool>
    
}

protocol WatchSettingWorkerProtocl {
    
    func fetchAutoanswer(id: String) -> Observable<Bool>
    func fetchSavepower(id: String) -> Observable<Bool>
    func updateSavepowerAndautoAnswer(id: String, autoanswer: Bool,savepower: Bool) -> Observable<Bool>
    
    func fetchLanguages(id: String) ->  Observable<[String]>
    func fetchLanguage(id: String) ->  Observable<String>
    func updateLanguage(id: String, _ language: String) -> Observable<Bool>
    
    func fetchshutTime(id: String) -> Observable<Date>
    func fetchbootTime(id: String) -> Observable<Date>
    func fetchoAutopoweronoff(id: String) -> Observable<Bool>
    func updateTime(id: String, bootTime: Date, shuntTime: Date,Autopoweronoff: Bool) -> Observable<Bool>
    
    func fetchUsePermission(id: String) -> Observable<[Bool]>
    func upUsePermission(id: String, btns: [Bool]) -> Observable<Bool>
    
    func fetchHoursFormat(id: String) -> Observable<Bool>
    func fetchGetTimeAuto(id: String) -> Observable<Bool>
    func fetchTimezone(id:String) -> Observable<Date> //发服务器为int
    func fetchSummerTime(id: String) -> Observable<Bool>
    func updateTimezones(id: String, hourformat: Bool, autotime: Bool,Timezone: Date, summertime: Bool) -> Observable<Bool>
    
    func fetchEmergencyNumbers(id: String) ->  Observable<[String]>
    func updateEmergencyNumbers(id: String, numbers: [String]) ->  Observable<Bool>
    
}

class WatchSettingsManager  {
    static let share = WatchSettingsManager()
    
    fileprivate var worker: WatchSettingWorkerProtocl!
    
    init() {
        worker = MoveApiWatchSettingsWorker()
    }
    
    func fetchAutoanswer() -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchAutoanswer(id: deviceId)
    }
    func fetchSavepower() -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchSavepower(id: deviceId)
    }
    func updateSavepowerAndautoAnswer(_ autoanswer: Bool,savepower: Bool) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateSavepowerAndautoAnswer(id: deviceId, autoanswer: autoanswer, savepower: savepower)
    }
   
    
    func fetchLanguages() ->  Observable<[String]>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<[String]>.empty()
        }
        return self.worker.fetchLanguages(id: deviceId)
    }
    
    func fetchLanguage() -> Observable<String> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<String>.empty()
        }
        return self.worker.fetchLanguage(id: deviceId)
    }
    
    func updateLanguage(_ language: String) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateLanguage(id: deviceId, language)
    }
    
    func fetchshutTime() -> Observable<Date>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Date>.empty()
        }
        return self.worker.fetchshutTime(id: deviceId)
        
    }
    func fetchbootTime() -> Observable<Date>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Date>.empty()
        }
        return self.worker.fetchbootTime(id: deviceId)

    }
    func fetchoAutopoweronoff() -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchoAutopoweronoff(id: deviceId)
    }
    
    func updateTime(_ bootTime: Date, shuntTime: Date,Autopoweronoff: Bool) -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateTime(id: deviceId, bootTime: bootTime, shuntTime: shuntTime,Autopoweronoff: Autopoweronoff)
    }
    
    func fetchUsePermission() -> Observable<[Bool]>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<[Bool]>.empty()
        }
        return self.worker.fetchUsePermission(id: deviceId)
    }
    func upUsePermission(_ btns: [Bool]) -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.upUsePermission(id: deviceId, btns: btns)
    }
    
    
    func fetchHoursFormat() -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchHoursFormat(id: deviceId)
    }
    func fetchGetTimeAuto() -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchGetTimeAuto(id: deviceId)
    }
    func fetchTimezone() -> Observable<Date> //发服务器为int
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Date>.empty()
        }
        return self.worker.fetchTimezone(id: deviceId)
    }
    func fetchSummerTime() -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchSummerTime(id: deviceId)
    }
    func updateTimezones(_ hourformat: Bool, autotime: Bool,Timezone: Date, summertime: Bool) -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateTimezones(id: deviceId, hourformat: hourformat, autotime: autotime, Timezone: Timezone, summertime: summertime)
    }
    
    func fetchEmergencyNumbers() ->  Observable<[String]> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<[String]>.empty()
        }
        return self.worker.fetchEmergencyNumbers(id: deviceId)
    }
    
    func updateEmergencyNumbers(with numbers: [String]) ->  Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateEmergencyNumbers(id: deviceId, numbers: numbers)
    }
    
}


class KidSettingsManager {
    static let shared = KidSettingsManager()
    
    fileprivate var worker: KidSettingsWorkerProtocl!
    
    init() {
        worker = MoveApiKidSettingsWorker()
    }
    
    func fetchSchoolTime() -> Observable<KidSetting.SchoolTime> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId else {
            return Observable<KidSetting.SchoolTime>.empty()
        }
        return self.worker.fetchSchoolTime(id: deviceId)
    }
    
    func updateSchoolTime(_ schoolTime: KidSetting.SchoolTime) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.updateSchoolTime(id: deviceId, schoolTime)
    }
    
    func updateAlarm(_ old: KidSetting.Reminder.Alarm, new: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.updateAlarm(deviceId: deviceId, old: old, new: new)
    }
    
    func creadAlarm(_ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.creadAlarm(deviceId: deviceId, alarm)
    }
    
//    func updateTodoList(_ old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool>
//    {
//        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
//            return Observable<Bool>.empty()
//        }
//        return worker.updateTodoList(deviceId: deviceId, old: old, new: new)
//    }
   
    func creadTodoLis( _ todolist: KidSetting.Reminder.ToDo) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.creadTodoLis(deviceId: deviceId, todolist)
    }
   
    func fetchreminder() -> Observable<KidSetting.Reminder>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId else {
            return Observable<KidSetting.Reminder>.empty()
        }
        return self.worker.fetchreminder(id: deviceId)
    }
    
    func updateReminder(_ reminder: KidSetting.Reminder) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.updateReminder(id: deviceId, reminder)
        
    }
    
}
