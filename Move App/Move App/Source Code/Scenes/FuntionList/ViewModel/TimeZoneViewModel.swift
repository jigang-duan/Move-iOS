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
        selectedTimezone: Driver<String>,
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
        
//        let down = Driver.combineLatest(hourformEnable,
//                                        autotimeEnable,
//                                        input.selectedTimezone,
//                                        summertimeEnable) { ($0, $1, $2, $3) }
//            .filter{ $0.2 != "" }
//        
//        self.saveFinish = down
//            .flatMapLatest { (hourform, autotime, timezone, summertime) in
//                manager.updateTimezones(hourformat: hourform,
//                                        autotime: autotime,
//                                        timezone: timezone,
//                                        summertime: autotime ? !autotime : summertime)
//                    .trackActivity(activitying)
//                    .asDriver(onErrorJustReturn: false)
//            }
        
        let updateHourform = input.hourform
            .flatMapLatest {
                manager.updateTimezones(hourformat: $0).trackActivity(activitying).asDriver(onErrorJustReturn: false)
            }
        
        let updateAutotime = input.autotime
            .flatMapLatest {
                manager.updateTimezones(autotime: $0, summertime: $0 ? !$0 : nil).trackActivity(activitying).asDriver(onErrorJustReturn: false)
            }
        
        let updateSelectedTimezone = input.selectedTimezone
            .filterEmpty()
            .flatMapLatest {
                manager.updateTimezones(timezone: $0).trackActivity(activitying).asDriver(onErrorJustReturn: false)
            }
        
        let updateSummertime = input.summertime
//            .withLatestFrom(autotimeEnable) { $1 ? !$1 : $0 }
            .flatMapLatest {
                manager.updateTimezones(summertime: $0).trackActivity(activitying).asDriver(onErrorJustReturn: false)
            }
        
        saveFinish = Driver.merge(updateHourform, updateAutotime, updateSelectedTimezone, updateSummertime)
    }
    
}




