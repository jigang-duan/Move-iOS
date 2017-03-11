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
    //let timezoneIdentifier: Driver<String>
    let summertimeEnable: Driver<Bool>
    let fetchtimezoneDate: Driver<Date>
    
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        hourform: Driver<Bool>,
        autotime: Driver<Bool>,
        timezone: Driver<TimeZone>,
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
            .asDriver(onErrorJustReturn: Date(timeIntervalSince1970: TimeInterval(TimeZone.current.secondsFromGMT())) )

        let fetchsummertime = manager.fetchSummerTime()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.summertimeEnable = Driver.of(fetchsummertime, input.summertime).merge()
        
        let timezoneTamp = input.timezone.asDriver().map({ Date(timeIntervalSince1970: TimeInterval($0.secondsFromGMT()))  })
        
        let down = Driver.combineLatest(hourformEnable , autotimeEnable, timezoneTamp, summertimeEnable) { ($0, $1, $2, $3) }

        
        self.saveFinish = down
            .flatMapLatest { (hourform, autotime, timezone, summertime) in
                manager.updateTimezones(hourform, autotime: autotime, Timezone: timezone, summertime: summertime)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}




