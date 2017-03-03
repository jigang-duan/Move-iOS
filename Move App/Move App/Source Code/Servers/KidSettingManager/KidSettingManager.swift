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
}

protocol WatchSettingWorkerProtocl {
    func fetchLanguages(id: String) ->  Observable<[String]>
    func fetchLanguage(id: String) ->  Observable<String>
    func updateLanguage(id: String, _ language: String) -> Observable<Bool>
    
    func fetchshutTime(id: String) -> Observable<Date>
    func fetchbootTime(id: String) -> Observable<Date>
    func fetchoAutopoweronoff(id: String) -> Observable<Bool>
    func updateTime(id: String, bootTime: Date, shuntTime: Date,Autopoweronoff: Bool) -> Observable<Bool>

}

class WatchSettingsManager  {
    static let share = WatchSettingsManager()
    
    fileprivate var worker: WatchSettingWorkerProtocl!
    
    init() {
        worker = MoveApiWatchSettingsWorker()
    }
    
    func fetchLanguages() ->  Observable<[String]>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<[String]>.empty()
        }
        return self.worker.fetchLanguages(id: deviceId)
    }
    
    func fetchLanguage() -> Observable<String> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<String>.empty()
        }
        return self.worker.fetchLanguage(id: deviceId)
    }
    
    func updateLanguage(_ language: String) -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateLanguage(id: deviceId, language)
    }
    
    func fetchshutTime() -> Observable<Date>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Date>.empty()
        }
        return self.worker.fetchshutTime(id: deviceId)
        
    }
    func fetchbootTime() -> Observable<Date>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Date>.empty()
        }
        return self.worker.fetchbootTime(id: deviceId)

    }
    func fetchoAutopoweronoff() -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchoAutopoweronoff(id: deviceId)
    }
    
    func updateTime(_ bootTime: Date, shuntTime: Date,Autopoweronoff: Bool) -> Observable<Bool>{
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateTime(id: deviceId, bootTime: bootTime, shuntTime: shuntTime,Autopoweronoff: Autopoweronoff)
    }
    
    
}


class KidSettingsManager {
    static let shared = KidSettingsManager()
    
    fileprivate var worker: KidSettingsWorkerProtocl!
    
    init() {
        worker = MoveApiKidSettingsWorker()
    }
    
    func fetchSchoolTime() -> Observable<KidSetting.SchoolTime> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<KidSetting.SchoolTime>.empty()
        }
        return self.worker.fetchSchoolTime(id: deviceId)
    }
    
    func updateSchoolTime(_ schoolTime: KidSetting.SchoolTime) -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return worker.updateSchoolTime(id: deviceId, schoolTime)
    }
    
    func updateAlarm(old: KidSetting.Reminder.Alarm, new: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return worker.updateAlarm(deviceId: deviceId, old: old, new: new)
    }
    
    func creadAlarm(_ alarm: KidSetting.Reminder.Alarm) -> Observable<Bool> {
        guard let deviceId = Me.shared.currDeviceID else {
            return Observable<Bool>.empty()
        }
        return worker.creadAlarm(deviceId: deviceId, alarm)
    }
}
