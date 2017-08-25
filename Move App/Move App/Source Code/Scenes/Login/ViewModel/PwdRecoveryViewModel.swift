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
        
        
        let emailInvalidte = input.email
            .map { email in
                return validation.validateEmail(email)
        }
        
        let emailNotEmpty = input.email
            .map { email in
                return email.characters.count > 0
        }
        
        self.doneEnabled = Driver.combineLatest(emailNotEmpty,sending) { vcode, sending in
                vcode && !sending
            }
            .distinctUntilChanged()
        
        
        let com = Driver.combineLatest(emailInvalidte, input.email){($0,$1)}
        
        self.doneResult  = input.doneTaps.withLatestFrom(com)
            .flatMapLatest({res, email in
                if res.isValid {
                    return userManager.sendVcode(to: email, type: 1)
                        .trackActivity(activity)
                        .map{ info in
                            self.sid = info.sid
                            return ValidationResult.ok(message: "Send Success.")
                        }
                        .asDriver(onErrorRecover: errorRecover)
                }else{
                    return Driver.just(res)
                }
            })
        
    
    }
    
}


fileprivate func errorRecover(_ error: Swift.Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if case WorkerError.webApi(let id, _, let msg) = _error {
        if id == 6 && msg == "Not found" {
            return Driver.just(ValidationResult.failed(message: R.string.localizable.id_not_found_email()))
        }
    }
    
    let msg = WorkerError.verifyErrorTransform(from: _error)
    return Driver.just(ValidationResult.failed(message: msg))
}
