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

    let reminderVariable = Variable(KidSetting.Reminder())
    
    let fetchReminder: Driver<KidSetting.Reminder>
    
    let activityIn: Driver<Bool>
    
    
    init(
        input: (
        update: Driver<Void>,
        delete: Driver<Void>,
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
        
        
        let deleteReminder = input.delete
            .withLatestFrom(reminderVariable.asDriver())
            .flatMapLatest({
                manager.updateReminder($0)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            })
            .flatMapLatest({_ in
                manager.fetchreminder().takeLast(1)
                    .asDriver(onErrorRecover: { _ in Driver.empty() })
            })
        
        let updateReminder = input.update
            .flatMapLatest({
                manager.fetchreminder()
                    .trackActivity(activitying)
                    .asDriver(onErrorRecover: { _ in Driver.empty() })
            })
        
        fetchReminder = Driver.of(updateReminder, deleteReminder).merge()
     


    }

    
    
}
