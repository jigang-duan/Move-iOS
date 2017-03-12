//
//  RegularshutdownViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/2.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class RegularshutdownViewModel {
    
    // outputs {
    
    //
    let openEnable: Driver<Bool>
    let bootTime: Driver<Date>
    let shutdownTime: Driver<Date>
    let saveFinish: Driver<Bool>
    
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        save: Driver<Void>,
        bootTime: Driver<Date>,
        shutdownTime: Driver<Date>,
        openEnable: Driver<Bool>
        ),
        dependency: (
        settingsManager: WatchSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let manager = dependency.settingsManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        self.bootTime = manager.fetchbootTime()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: DateUtility.zone7hour())
        
        self.shutdownTime = manager.fetchshutTime()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: DateUtility.zone16hour())
        
        self.openEnable = manager.fetchoAutopoweronoff()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        
        
        let down = Driver.combineLatest(input.shutdownTime, input.bootTime, input.openEnable) { ($0, $1, $2) }
        
        self.saveFinish = input.save
            .withLatestFrom(down)
            .flatMapLatest { (bootTime,shutdownTime,openEnable) in
                manager.updateTime(bootTime, shuntTime: shutdownTime, Autopoweronoff: openEnable)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
        
        
        
    }

    
}
