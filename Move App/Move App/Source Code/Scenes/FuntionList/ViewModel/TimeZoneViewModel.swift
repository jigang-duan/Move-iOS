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
    let timezoneDate: Driver<String>
    
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        hourform: Driver<Bool>,
        autotime: Driver<Bool>,
        timezone: Driver<String>,
        summertime: Driver<Bool>
        ),
        dependency: (
        settingsManager: WatchSettingsManager,
        validation: DefaultValidation,
        configChanged: Observable<Void>,
        wireframe: Wireframe
        )
        ) {
        
        let manager = dependency.settingsManager
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        let fetchHourform = manager.fetchHoursFormat()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: true)
        self.hourformEnable = Driver.of(fetchHourform, input.hourform).merge()
        
        let fetchAutotime = manager.fetchGetTimeAuto()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: true)
        self.autotimeEnable = Driver.of(fetchAutotime, input.autotime).merge()
        
        timezoneDate = dependency.configChanged.asDriver(onErrorJustReturn: ())
            .startWith(())
            .flatMapLatest {
                manager.fetchTimezone().takeLast(1)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: "")
            }
            .filterEmpty()

        let fetchsummertime = manager.fetchSummerTime()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.summertimeEnable = Driver.of(fetchsummertime, input.summertime).merge()
        
        
        let down = Driver.combineLatest(hourformEnable , autotimeEnable, input.timezone, summertimeEnable) { ($0, $1, $2, $3) }
            .filter{ $0.2 != "" }
        
        self.saveFinish = down
            .flatMapLatest { (hourform, autotime, timezone, summertime) in
                manager.updateTimezones(hourform, autotime: autotime, timezone: timezone, summertime: summertime)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
    }
    
}




