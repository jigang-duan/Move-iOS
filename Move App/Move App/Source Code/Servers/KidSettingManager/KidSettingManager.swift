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
    func addAlarm(deviceId: String, _ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool>
    
    func updateTodoList(deviceId: String, old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool>
    func addTodo(deviceId: String, _ todo: KidSetting.Reminder.ToDo) -> Observable<Bool>
    
    func fetchreminder(id: String) -> Observable<KidSetting.Reminder>
    func updateReminder(id: String, _ reminder: KidSetting.Reminder) -> Observable<Bool>
    
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
    
    func addAlarm(_ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.addAlarm(deviceId: deviceId, alarm)
    }
    
    func updateTodoList(_ old : KidSetting.Reminder.ToDo, new: KidSetting.Reminder.ToDo) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.updateTodoList(deviceId: deviceId, old: old, new: new)
    }
   
    func addTodo( _ todo: KidSetting.Reminder.ToDo) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return worker.addTodo(deviceId: deviceId, todo)
    }
   
    func fetchreminder() -> Observable<KidSetting.Reminder>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId else {
            return Observable.empty()
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
