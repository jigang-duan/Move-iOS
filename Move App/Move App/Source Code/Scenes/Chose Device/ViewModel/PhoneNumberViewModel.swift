//
//  PhoneNumberViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/28.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class PhoneNumberViewModel {
    
    let phoneInvalidte: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let nextEnabled: Driver<Bool>
    let nextResult: Driver<ValidationResult>
    
    
    init(
        input: (
        phone: Driver<String>,
        nextTaps: Driver<Void>
        ),
        dependency: (
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let userManager = dependency.userManager
        _ = dependency.validation
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        phoneInvalidte = input.phone
            .map {  phone in
                if phone.characters.count > 0{
                    return ValidationResult.ok(message: "")
                }
                return ValidationResult.empty
        }
        
        
        self.nextEnabled = Driver.combineLatest(
            phoneInvalidte,
            sending) { imei, sending in
                imei.isValid &&
                    !sending
            }
            .distinctUntilChanged()
        
        
        let email = userManager.getProfile().map({$0.email}).filterNil().asDriver(onErrorJustReturn: "")
        
        self.nextResult = input.nextTaps.withLatestFrom(email)
            .flatMapLatest({ email in
                return userManager.sendVcode(to: email)
                    .trackActivity(activity)
                    .map({_ in
                        return ValidationResult.ok(message: "Send Success.")
                    })
                    .asDriver(onErrorRecover: pwdRecoveryErrorRecover)
            })
        
    }
    
}

fileprivate func pwdRecoveryErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}

