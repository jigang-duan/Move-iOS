//
//  SchoolTimeViewModel.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

class SchoolTimeViewModel {
    // outputs {
    
    //
    let openEnable: Driver<Bool>
    let amStartDate: Driver<Date>
    let amEndDate: Driver<Date>
    let pmStartDate: Driver<Date>
    let pmEndDate: Driver<Date>
    let dayFromWeek: Driver<[Bool]>
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        save: Driver<Void>,
        week: Driver<[Bool]>,
        amStart: Driver<Date>,
        amEnd: Driver<Date>,
        pmStart: Driver<Date>,
        pmEnd: Driver<Date>
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

        let schoolTimeFromNetwork = manager.fetchSchoolTime()
            .trackActivity(activitying)
            .shareReplay(1)
        
        self.dayFromWeek = schoolTimeFromNetwork
            .map({$0.days})
            .asDriver(onErrorJustReturn: [])
        
        self.amStartDate = schoolTimeFromNetwork
            .map({$0.amStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone7hour())
        
        self.amEndDate = schoolTimeFromNetwork
            .map({$0.amEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone12hour())
        
        self.pmStartDate = schoolTimeFromNetwork
            .map({$0.pmStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone14hour())
        
        self.pmEndDate = schoolTimeFromNetwork
            .map({$0.pmEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone16hour())
        
        self.openEnable = Driver.just(true)
        
        let schoolTime = Driver.combineLatest(input.amStart,
                                              input.amEnd,
                                              input.pmStart,
                                              input.pmEnd,
                                              input.week) {
            KidSetting.SchoolTime(
                amStartPeriod: $0,
                amEndPeriod: $1,
                pmStartPeriod: $2,
                pmEndPeriod: $3,
                days: $4)
        }
        self.saveFinish = input.save
            .withLatestFrom(schoolTime)
            .flatMapLatest { schoolTime in
                manager.updateSchoolTime(schoolTime)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
    }
    
}
