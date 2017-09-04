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
    
    let openEnableVariable = Variable(false)
    let amStartDateVariable = Variable(DateUtility.zone7hour())
    let amEndDateVariable = Variable(DateUtility.zone12hour())
    let pmStartDateVariable = Variable(DateUtility.zone14hour())
    let pmEndDateVariable = Variable(DateUtility.zone16hour())
    
    let dayFromWeekVariable = Variable([false, false, false, false, false, false, false])
    
    var saveFinish: Driver<Bool>?
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        save: Driver<Void>,
        empty: Void
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
        
        schoolTimeFromNetwork
            .map({$0.days})
            .asDriver(onErrorJustReturn: [])
            .drive(self.dayFromWeekVariable)
            .addDisposableTo(disposeBag)
        
        schoolTimeFromNetwork
            .map({$0.amStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone7hour())
            .drive(self.amStartDateVariable)
            .addDisposableTo(disposeBag)
        
        schoolTimeFromNetwork
            .map({$0.amEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone12hour())
            .drive(self.amEndDateVariable)
            .addDisposableTo(disposeBag)
        
        schoolTimeFromNetwork
            .map({$0.pmStartPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone14hour())
            .drive(self.pmStartDateVariable)
            .addDisposableTo(disposeBag)
        
        schoolTimeFromNetwork
            .map({$0.pmEndPeriod})
            .filterNil()
            .asDriver(onErrorJustReturn: DateUtility.zone16hour())
            .drive(self.pmEndDateVariable)
            .addDisposableTo(disposeBag)
        
        schoolTimeFromNetwork
            .map({$0.active})
            .filterNil()
            .asDriver(onErrorJustReturn: false)
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
            .withLatestFrom(dayFromWeekVariable.asDriver())
            .filter{$0.contains(true)}
            .withLatestFrom(schoolTime)
//            .filter {
//                $0.amStartPeriod != Date(timeIntervalSince1970: 0)
//                    && $0.amEndPeriod != Date(timeIntervalSince1970: 0)
//                    && $0.pmStartPeriod != Date(timeIntervalSince1970: 0)
//                    && $0.pmEndPeriod != Date(timeIntervalSince1970: 0) }
            .flatMapLatest { schoolTime in
                manager.updateSchoolTime(schoolTime)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
        
    }

}
