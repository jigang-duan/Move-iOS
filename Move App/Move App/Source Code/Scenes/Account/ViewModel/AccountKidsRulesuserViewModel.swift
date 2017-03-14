//
//  AccountKidsRulesuserViewModel.swift
//  Move App
//
//  Created by LX on 2017/3/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountKidsRulesuserViewModel {
    // outputs {
    let savePowerEnable: Driver<Bool>
    let autoAnswereEnable: Driver<Bool>
    
    let saveFinish: Driver<Bool>
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        savePower: Driver<Bool>,
        autoAnswer: Driver<Bool>
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
        
        let fetchsavePower = manager.fetchSavepower()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.savePowerEnable = Driver.of(fetchsavePower, input.savePower).merge()
        
        let fetchautoAnswer = manager.fetchAutoanswer()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        self.autoAnswereEnable = Driver.of(fetchautoAnswer, input.autoAnswer).merge()
        
        
        let down = Driver.combineLatest(savePowerEnable , autoAnswereEnable) { ($0, $1) }
        
        
        self.saveFinish = down
            .flatMapLatest { (savepower, autoanswer) in
                manager.updateSavepowerAndautoAnswer(autoanswer, savepower: savepower)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
        }
    }
   
}
