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
    
    //
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        save: Driver<Void>,
        week: Driver<[Bool]>,
        alarmDate: Driver<Date>,
        alarmExited: KidSetting.Reminder.Alarm?
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
        
        let newAlarm = Driver.combineLatest(input.week, input.alarmDate) { KidSetting.Reminder.Alarm(alarmAt: $1, day: $0) }
        self.saveFinish = input.save.withLatestFrom(newAlarm).asObservable()
            .flatMapLatest({ alarm -> Observable<Bool> in
                return input.alarmExited != nil ?
                    manager.updateAlarm(old: input.alarmExited! , new: alarm).trackActivity(activitying) :
                    manager.creadAlarm(alarm).trackActivity(activitying)
            })
            .asDriver(onErrorJustReturn: false)
        
    }
}
