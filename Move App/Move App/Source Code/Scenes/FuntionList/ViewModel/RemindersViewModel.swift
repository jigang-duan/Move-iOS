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
    
    let alarmsVariable: Variable<[KidSetting.Reminder.Alarm]> = Variable([])
    let todosVariable: Variable<[KidSetting.Reminder.ToDo]> = Variable([])
    
    let fetchAlarms: Driver<[KidSetting.Reminder.Alarm]>
    let fetchTodos: Driver<[KidSetting.Reminder.ToDo]>
    
    //let delectFinish: Driver<Bool>
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        deldect: Driver<Void>,
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
             .shareReplay(1)
        //到 控制器无数据了。。
        fetchAlarms = reminderInfomation.map({ $0.alarms }).asDriver(onErrorJustReturn: [])
        fetchTodos = reminderInfomation.map({ $0.todo }).asDriver(onErrorJustReturn: [])
     
        //缺少删除参数
//        let reminder = Driver.combineLatest(<#T##collection: C##C#>, <#T##resultSelector: ([τ_0_0]) throws -> R##([τ_0_0]) throws -> R#>)
//        
//        self.delectFinish = input.deldect
//            .withLatestFrom(reminder)
//            .flaMapLatest{reminder in
//                    manager.updateReminder(reminder)
//                        .trackActivity(activitying)
//                        .asDriver(onErrorJustReturn: false)
//        }


    }

    
    
}
