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
