//
//  MoveApiWatchSettingsWorker.swift
//  Move App
//
//  Created by jiang.duan on 2017/6/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class MoveApiWatchSettingsWorker: WatchSettingWorkerProtocl {
    
    func fetchautoPosistion(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.auto_positiion ?? false }
    }
    
    func fetchAutoanswer(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.auto_answer ?? false }
    }
    
    func fetchEmergencyNumbers(id: String) ->  Observable<[String]> {
        return MoveApi.Device.fetchSetting(deviceId: id).map { $0.sos ?? [] }
    }
    
    func fetchLanguages(id: String) ->  Observable<[String]> {
        return MoveApi.Device.getProperty(deviceId: id).map { $0.languages ?? [] }
    }
    
    func fetchLanguage(id: String) ->  Observable<String> {
        return MoveApi.Device.fetchSetting(deviceId: id).map { $0.language ?? "" }
    }
    
    func fetchshutTime(id: String) -> Observable<Date>{
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.shutdown_time ?? DateUtility.zone16hour() }
    }
    
    func fetchbootTime(id: String) -> Observable<Date>{
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.boot_time ?? DateUtility.zone7hour() }
    }
    
    func fetchoAutopoweronoff(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.auto_power_onoff ?? false }
    }
    
    func fetchUsePermission(id: String) -> Observable<[Bool]>{
        return MoveApi.Device.fetchSetting(deviceId: id).map{ wrappbool(perint: $0.permissions) }
    }
    
    func fetchHoursFormat(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.hour24 ?? true }
    }
    
    func fetchGetTimeAuto(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.auto_time ?? true }
    }
    
    func fetchTimezone(id:String) -> Observable<String> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.timezone ?? "" }
    }
    
    func fetchSummerTime(id: String) -> Observable<Bool> {
        return MoveApi.Device.fetchSetting(deviceId: id).map{ $0.dst ?? false }
    }
    
    
    func updateAutoPosition(id: String, autoPosition: Bool) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest{  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.auto_positiion = autoPosition
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            }
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updateAnswerAndPosition(id: String, autoanswer: Bool, autoPosition: Bool) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest{  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.auto_answer = autoanswer
                _setting.auto_positiion = autoPosition
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            }
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func update(deviceId: String, autoPosistion: Bool) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: deviceId)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.auto_positiion = autoPosistion
                return MoveApi.Device.setting(deviceId: deviceId, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    
    
    func updateEmergencyNumbers(id: String, numbers: [String]) ->  Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.sos = numbers
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    
    
    func updateLanguage(id: String, _ language: String) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.language = language
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updateTime(id: String, bootTime: Date, shuntTime: Date, Autopoweronoff: Bool) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.boot_time = bootTime
                _setting.shutdown_time = shuntTime
                _setting.auto_power_onoff = Autopoweronoff
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func upUsePermission(id: String, btns: [Bool]) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                
                var peris: [Int] = []
                for (i, btn) in btns.enumerated() {
                    if btn {
                        peris.append(i+1)
                    }
                }
                
                _setting.permissions = peris
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updateTimezones(id: String,
                         hourformat: Bool? = nil,
                         autotime: Bool? = nil,
                         timezone: String? = nil,
                         summertime: Bool? = nil) -> Observable<Bool> {
        return MoveApi.Device.getSetting(deviceId: id)
            .flatMapLatest({  setting -> Observable<MoveApi.ApiError> in
                var _setting = setting
                _setting.dst = summertime ?? setting.dst
                _setting.auto_time = autotime ?? setting.auto_time
                _setting.hour24 = hourformat ?? setting.hour24
                _setting.timezone = timezone ?? setting.timezone
                return MoveApi.Device.setting(deviceId: id, settingInfo: _setting)
            })
            .map(errorTransform)
            .catchError(errorHandle)
    }
}

fileprivate func wrappbool(perint: [Int]?) -> [Bool] {
    guard let perint = perint else { return [false, false, false, false] }
    return [
        perint.contains(1),
        perint.contains(2),
        perint.contains(3),
        perint.contains(4)
    ]
}
