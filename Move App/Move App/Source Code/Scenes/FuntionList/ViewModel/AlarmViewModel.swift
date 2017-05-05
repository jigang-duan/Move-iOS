//
//  AlarmViewModel.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AlarmViewModel {
    // outputs {

    var saveFinish: Driver<Bool>?
    let activityIn: Driver<Bool>
    
    // }
    init(
        input: (
        save: Driver<Void>,
        week: Driver<[Bool]>,
        alarmDate: Driver<Date>,
        active: Driver<Bool>
//        alarmExited: KidSetting.Reminder.Alarm?
        ),
        dependency: (
        kidSettingsManager: KidSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        let manager = dependency.kidSettingsManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
 
        
        let newAlarm = Driver.combineLatest(input.week, input.alarmDate,input.active) { KidSetting.Reminder.Alarm(alarmAt: $1, day: self.sortWeek($0), active: $2) }
        self.saveFinish = input.save.withLatestFrom(newAlarm).asObservable()
            .flatMapLatest({ alarm -> Observable<Bool> in
                return
//                input.alarmExited != nil ?
//                    manager.updateAlarm(input.alarmExited! , new: alarm).trackActivity(activitying) :
                    manager.creadAlarm(alarm).trackActivity(activitying)
            })
            .asDriver(onErrorJustReturn: false)
        
    }
    
    
    func sortWeek(_ flags: [Bool]) -> [Bool] {
        var fs = flags
        let flag = fs.first!
        _ = fs.remove(at: 0)
        _ = fs.append(flag)
        return fs
    }
}
