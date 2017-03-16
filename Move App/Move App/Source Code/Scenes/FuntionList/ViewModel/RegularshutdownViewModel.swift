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

    let bootTime: Driver<Date>
    let shutdownTime: Driver<Date>
    let autoOnOffEnable: Driver<Bool>
    var saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        bootTime: Driver<Date>,
        shutdownTime: Driver<Date>,
        autoOnOff: Driver<Bool>,
        save: Driver<Void>
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
        
        let fetchAutoOnOff = manager.fetchoAutopoweronoff()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.autoOnOffEnable = Driver.of(fetchAutoOnOff,input.autoOnOff).merge()
        
        
        let down = Driver.combineLatest(input.bootTime,input.shutdownTime,input.autoOnOff) { ($0, $1, $2) }
        
        self.saveFinish = down
            .flatMapLatest { (bootTime,shutdownTime,autoOnOff) in
                manager.updateTime(bootTime, shuntTime: shutdownTime, Autopoweronoff: autoOnOff)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }

//        self.saveFinish = input.save
//            .withLatestFrom(down)
//            .flatMapLatest { (bootTime,shutdownTime,autoOnOff) in
//                manager.updateTime(bootTime, shuntTime: shutdownTime, Autopoweronoff: autoOnOff)
//                    .trackActivity(activitying)
//                    .asDriver(onErrorJustReturn: false)
//        }
//        
        
        
    }

    
}
