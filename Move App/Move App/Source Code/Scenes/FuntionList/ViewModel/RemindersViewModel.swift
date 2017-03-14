//
//  RemindersViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class RemindersViewModel {
    // outputs {
    
    let reminderVariable: Variable<KidSetting.Reminder> = Variable(KidSetting.Reminder())
    
    let fetchReminder: Driver<KidSetting.Reminder>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        update: Driver<Void>,
        delect: Driver<Void>,
        empty: Void
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
        
        let reminderInfomation = manager.fetchreminder()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: KidSetting.Reminder())
        
        let delectReminder = input.delect
            .withLatestFrom(reminderVariable.asDriver()).debug()
            .flatMapLatest({
                manager.updateReminder($0)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }).debug()
            .flatMapLatest({_ in
                reminderInfomation.debug()
            })
        
        let updateReminder = input.update
            .flatMapLatest({
                reminderInfomation
            })
        
        fetchReminder = Driver.of(updateReminder, delectReminder).merge()
     


    }

    
    
}
