//
//  File.swift
//  Move App
//
//  Created by LX on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ToDoListViewModel {
    
    // outputs {
    
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        save: Driver<Void>,
        topic: Driver<String>,
        content: Driver<String>,
        startime: Driver<Date>,
        endtime: Driver<Date>,
        repeatcount: Driver<Int>
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
        
        
        
        let newTodo = Driver.combineLatest(input.topic,input.content,input.startime,input.endtime,input.repeatcount) {
            KidSetting.Reminder.ToDo(topic: $0, content: $1, start: $2, end: $3, repeatCount: $4)
            
        }
        self.saveFinish = input.save.withLatestFrom(newTodo).asObservable()
            .flatMapLatest({ todo -> Observable<Bool> in
                return
                    manager.addTodo(todo).trackActivity(activitying)
            })
            .asDriver(onErrorJustReturn: false)

        
    }

    
}
