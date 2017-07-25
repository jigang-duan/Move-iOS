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
    let autoAnswereEnable: Driver<Bool>
    let autoPosistionEnable: Driver<Bool>
    
    let saveFinish: Driver<Bool>
    let activityIn: Driver<Bool>
    // }
    
    init(
        input: (
        autoAnswer: Driver<Bool>,
        autoPosistion: Driver<Bool>
        ),
        dependency: (
        settingsManager: WatchSettingsManager,
        validation: DefaultValidation,
        wireframe: AlertWireframe
        )
        ) {
        
        let manager = dependency.settingsManager
        let wireframe = dependency.wireframe
        
        let activitying = ActivityIndicator()
        self.activityIn = activitying.asDriver()
        
        
        let fetchautoAnswer = manager.fetchAutoanswer()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        
        self.autoAnswereEnable = Driver.of(fetchautoAnswer, input.autoAnswer).merge()
        
        let fetchautoPosistion = manager.fetchautoPosistion()
            .trackActivity(activitying)
            .asDriver(onErrorJustReturn: false)
        
        let stringOnTrankingMode = R.string.localizable.id_turn_on_auto_position()
        
        let stringOffTrankingMode = R.string.localizable.id_turn_off_auto_position()
        let selectAutoPosistion = input.autoPosistion
            .flatMapLatest { (turning) in
                wireframe.promptYHFor(turning ? stringOnTrankingMode : stringOffTrankingMode,
                                    cancelAction: CommonResult.cancel, action: CommonResult.ok)
                    .map{ $0.isOK }
                    .asDriver(onErrorJustReturn: false)
                    .map{ $0 ? turning : !turning }
            }
        
        self.autoPosistionEnable = Driver.of(fetchautoPosistion, selectAutoPosistion).merge()
        
        let down = Driver.combineLatest( autoAnswereEnable , autoPosistionEnable.distinctUntilChanged()) { ($0, $1) }
        
        self.saveFinish = down
            .flatMapLatest { ( autoanswer, autoPosistion) in
                manager.updateAnswerAndPosition(autoanswer, autoPosition: autoPosistion)
                    .trackActivity(activitying)
                    .asDriver(onErrorJustReturn: false)
            }
    }
   
}
