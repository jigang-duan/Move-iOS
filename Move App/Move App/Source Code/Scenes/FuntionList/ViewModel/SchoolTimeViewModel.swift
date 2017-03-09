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
    //let openEnable: Driver<Bool>
//    let amStartDate: Driver<Date>
//    let amEndDate: Driver<Date>
//    let pmStartDate: Driver<Date>
//    let pmEndDate: Driver<Date>
//    let dayFromWeek: Driver<[Bool]>
    let openEnableVariable = Variable(false)
    let amStartDateVariable = Variable(DateUtility.zone7hour())
    let amEndDateVariable = Variable(DateUtility.zone12hour())
    let pmStartDateVariable = Variable(DateUtility.zone14hour())
    let pmEndDateVariable = Variable(DateUtility.zone16hour())
    let dayFromWeekVariable = Variable([false, false, false, false, false, false, false])
    
    let saveFinish: Driver<Bool>
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        save: Driver<Void>,
        week: Driver<[Bool]>,
        openEnable: Driver<Bool>,
        amStart: Driver<Date>,
        amEnd: Driver<Date>,
        pmStart: Driver<Date>,
        pmEnd: Driver<Date>
        ),
        dependency: (
        kidSettingsManager: KidSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe,
        disposeBag: DisposeBag
        )
        ) {
        
        let manager = dependency.kidSettingsManager
        let disposeBag = dependency.disposeBag
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()

        let schoolTimeFromNetwork = manager.fetchSchoolTime()
            .trackActivity(activitying)
            .shareReplay(1)
        
        //self.dayFromWeek =
        schoolTimeFromNetwork
            .map({$0.days})
            .asDriver(onErrorJustReturn: [])
            .drive(self.dayFromWeekVariable)
            .addDisposableTo(disposeBag)
        
        //self.amStartDate =
        schoolTimeFromNetwork
            .map({$0.amStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone7hour())
            .drive(self.amStartDateVariable)
            .addDisposableTo(disposeBag)
        
        //self.amEndDate =
        schoolTimeFromNetwork
            .map({$0.amEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone12hour())
            .drive(self.amEndDateVariable)
            .addDisposableTo(disposeBag)
        
        //self.pmStartDate =
        schoolTimeFromNetwork
            .map({$0.pmStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone14hour())
            .drive(self.pmStartDateVariable)
            .addDisposableTo(disposeBag)
        
        //self.pmEndDate =
        schoolTimeFromNetwork
            .map({$0.pmEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone16hour())
            .drive(self.pmEndDateVariable)
            .addDisposableTo(disposeBag)
        
        //self.openEnable =
        schoolTimeFromNetwork
            .map({$0.active})
            .filterNil()
            .asDriver(onErrorJustReturn: false)
            .startWith(false)
            .drive(self.openEnableVariable)
            .addDisposableTo(disposeBag)
        
        let schoolTime = Driver.combineLatest(amStartDateVariable.asDriver(),
                                              amEndDateVariable.asDriver(),
                                              pmStartDateVariable.asDriver(),
                                              pmEndDateVariable.asDriver(),
                                              dayFromWeekVariable.asDriver(),
                                              openEnableVariable.asDriver()) {
            KidSetting.SchoolTime(
                amStartPeriod: $0,
                amEndPeriod: $1,
                pmStartPeriod: $2,
                pmEndPeriod: $3,
                days: $4,
                active: $5)
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
