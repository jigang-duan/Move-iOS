//
//  EmergencyNumberViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EmergencyNumberViewModel {
    
    let phoneInvalidte: Driver<ValidationResult>
    
    var sending: Driver<Bool>
    
    var saveEnable: Driver<Bool>?
    var saveResult: Driver<ValidationResult>?
    
    init (input: (
        phone: Driver<String>,
        saveTaps: Driver<Void>
        ),
          dependency: (
        watchManager: WatchSettingsManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let watchManager = dependency.watchManager
        let validation = dependency.validation
        let _ = dependency.wireframe
        
        
        phoneInvalidte  = input.phone.map({ph in
            return validation.validateMultiPhones(ph)
        })
    
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        
        saveEnable = Driver.combineLatest(phoneInvalidte, sending) { phone, sending in
                 phone.isValid && !sending
            }
            .distinctUntilChanged()
        
        
        
        saveResult = input.saveTaps.asDriver()
            .withLatestFrom(input.phone)
            .flatMapLatest({ ph in
                var phs: [String] = []
                if ph.contains(",") {
                    phs = ph.components(separatedBy: ",")
                }else{
                    phs = [ph]
                }
                return watchManager.updateEmergencyNumbers(with: phs)
                    .trackActivity(activity)
                    .map({_ in
                    return ValidationResult.ok(message: "success")
                }).asDriver(onErrorRecover: commonErrorRecover)
        })
        
      
    }
}




