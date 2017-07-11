//
//  WatchSettingsManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/6/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


protocol WatchSettingWorkerProtocl {
    
    func fetchautoPosistion(id: String) -> Observable<Bool>
    func fetchAutoanswer(id: String) -> Observable<Bool>
    func updateAutoPosition(id: String, autoPosition: Bool) -> Observable<Bool>
    func updateAnswerAndPosition(id: String, autoanswer: Bool,autoPosition: Bool) -> Observable<Bool>
    func update(deviceId: String, autoPosistion: Bool) -> Observable<Bool>
    
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
    func fetchTimezone(id:String) -> Observable<String>
    func fetchSummerTime(id: String) -> Observable<Bool>
    func updateTimezones(id: String, hourformat: Bool, autotime: Bool,timezone: String, summertime: Bool) -> Observable<Bool>
    
    func fetchEmergencyNumbers(id: String) ->  Observable<[String]>
    func updateEmergencyNumbers(id: String, numbers: [String]) ->  Observable<Bool>
    
}

class WatchSettingsManager  {
    static let share = WatchSettingsManager()
    
    fileprivate var worker: WatchSettingWorkerProtocl!
    
    init() {
        worker = MoveApiWatchSettingsWorker()
    }
    
    func fetchautoPosistion(devID: String? = nil) -> Observable<Bool> {
        guard let deviceId = devID ?? DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchautoPosistion(id: deviceId)
    }
    
    func fetchAutoanswer() -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchAutoanswer(id: deviceId)
    }
    
    
    func updateAnswerAndPosition(_ autoanswer: Bool, autoPosition: Bool) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateAnswerAndPosition(id: deviceId, autoanswer: autoanswer, autoPosition: autoPosition)
    }
    
    func updateAutoPosition(_ autoPosition: Bool) -> Observable<Bool>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateAutoPosition(id: deviceId, autoPosition: autoPosition)
    }
    
    func update(deviceId: String? = nil, autoPosistion: Bool) -> Observable<Bool> {
        guard let deviceId = deviceId ?? DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.update(deviceId: deviceId, autoPosistion: autoPosistion)
    }
    
    func fetchLanguages() ->  Observable<[String]>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchLanguages(id: deviceId)
    }
    
    func fetchLanguage() -> Observable<String> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchLanguage(id: deviceId)
    }
    
    func updateLanguage(_ language: String) -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.updateLanguage(id: deviceId, language)
    }
    
    func fetchshutTime() -> Observable<Date>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchshutTime(id: deviceId)
        
    }
    
    func fetchbootTime() -> Observable<Date>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
        }
        return self.worker.fetchbootTime(id: deviceId)
        
    }
    
    func fetchoAutopoweronoff() -> Observable<Bool> {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable.empty()
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
            return Observable.empty()
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
    func fetchTimezone() -> Observable<String>
    {
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<String>.empty()
        }
        return self.worker.fetchTimezone(id: deviceId)
    }
    func fetchSummerTime() -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.fetchSummerTime(id: deviceId)
    }
    func updateTimezones(_ hourformat: Bool, autotime: Bool,timezone: String, summertime: Bool) -> Observable<Bool>{
        guard let deviceId = DeviceManager.shared.currentDevice?.deviceId  else {
            return Observable<Bool>.empty()
        }
        return self.worker.updateTimezones(id: deviceId, hourformat: hourformat, autotime: autotime, timezone: timezone, summertime: summertime)
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

