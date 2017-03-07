//
//  UsepermissionViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/4.
//  Copyright © 2017年 TCL Com. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

class UsepermissionViewModel {
    // outputs {
    
    //
    let selectBtns: Driver<[Bool]>
    let saveFinish: Driver<Bool>
    
    
    let activityIn: Driver<Bool>
    
    // }
    
    init(
        input: (
        btn0: Driver<Bool>,
        btn1: Driver<Bool>,
        btn2: Driver<Bool>,
        btn3: Driver<Bool>,
        btn4: Driver<Bool>
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
 
        self.selectBtns = manager.fetchUsePermission()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: [])
            .startWith([true,true,true,true,true])
        
        let selectPermission = Driver.combineLatest(input.btn0, input.btn1, input.btn2, input.btn3, input.btn4) { [$0, $1, $2, $3, $4] }
        self.saveFinish = Driver.of(input.btn0, input.btn1, input.btn2, input.btn3, input.btn4).merge()
            .withLatestFrom(selectPermission)
            .flatMapLatest { selectBtns in
                manager.upUsePermission(selectBtns)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }

}
