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
    
    private func unwrapping(schoolTime: KidSetting.SchoolTime) -> MoveApi.SchoolTime {
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
        return wrap
    }
    
    private func wrappingSchoolTime(_ settings: MoveApi.DeviceSetting) -> KidSetting.SchoolTime {
        return self.wrapping(schoolTime: settings.school_time)
    }
    
    private func wrapping(schoolTime: MoveApi.SchoolTime?) -> KidSetting.SchoolTime {
        guard let time = schoolTime else {
            return KidSetting.SchoolTime(
                amStartPeriod: DateUtility.zone7hour(),
                amEndPeriod: DateUtility.zone12hour(),
                pmStartPeriod: DateUtility.zone14hour(),
                pmEndPeriod: DateUtility.zone16hour(),
                days: [false, false, false, false, false, false, false])
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
            days: days)
        
    }
    
}
