//
//  PwdRecoveryViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class PwdRecoveryViewModel {
    
    let emailInvalidte: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let doneEnabled: Driver<Bool>
    var doneResult: Driver<ValidationResult>?
    
    var sid: String?
    
    init(
        input: (
        email: Driver<String>,
        doneTaps: Driver<Void>
        ),
        dependency: (
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let userManager = dependency.userManager
        let validation = dependency.validation
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        emailInvalidte = input.email
            .map { email in
                return validation.validateEmail(email)
        }
        
        
        self.doneEnabled = Driver.combineLatest(
            emailInvalidte,
            sending) { vcode, sending in
                vcode.isValid &&
                    !sending
            }
            .distinctUntilChanged()
        
        
        
        self.doneResult  = input.doneTaps.withLatestFrom(input.email)
            .flatMapLatest({email in
                return userManager.sendVcode(to: email)
                    .trackActivity(activity)
                    .map{ info in
                        self.sid = info.sid
                        return ValidationResult.ok(message: "Send Success.")
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
        
    
    }
    
}
