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
        
        
        let phoneNotEmpty = input.phone.map({ph in
            return ph.characters.count >= 0
        })
        
        saveEnable = Driver.combineLatest(phoneNotEmpty, sending) { phone, sending in
                 phone && !sending
            }
            .distinctUntilChanged()
        
        
        
        let com = Driver.combineLatest(phoneInvalidte, input.phone){($0,$1)}
        
        saveResult = input.saveTaps.asDriver()
            .withLatestFrom(com)
            .flatMapLatest({ res, ph in
//                if res.isValid {
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
//                }else{
//                    return Driver.just(res)
//                }
        })
        
      
    }
}




