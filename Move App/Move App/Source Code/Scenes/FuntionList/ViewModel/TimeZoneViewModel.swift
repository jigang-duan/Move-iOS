//
//  TimeZoneViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/6.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

class TimeZoneViewModel {
    // outputs {
    let hourformEnable: Driver<Bool>
    let autotimeEnable: Driver<Bool>
    let summertimeEnable: Driver<Bool>
    let fetchtimezoneDate: Driver<Int>
    
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        hourform: Driver<Bool>,
        autotime: Driver<Bool>,
        timezone: Driver<Int>,
        summertime: Driver<Bool>
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
        
        let fetchHourform = manager.fetchHoursFormat()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.hourformEnable = Driver.of(fetchHourform, input.hourform).merge()
        
        let fetchAutotime = manager.fetchGetTimeAuto()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.autotimeEnable = Driver.of(fetchAutotime, input.autotime).merge()
        
        fetchtimezoneDate = manager.fetchTimezone()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: 0 )

        let fetchsummertime = manager.fetchSummerTime()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.summertimeEnable = Driver.of(fetchsummertime, input.summertime).merge()
        
        
        let down = Driver.combineLatest(hourformEnable , autotimeEnable, input.timezone, summertimeEnable) { ($0, $1, $2, $3) }

        
        self.saveFinish = down
            .flatMapLatest { (hourform, autotime, timezone, summertime) in
                manager.updateTimezones(hourform, autotime: autotime, Timezone: timezone, summertime: summertime)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}




