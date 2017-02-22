//
//  ProtectAccountViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class ProtectAccountViewModel {
    
    let vcodeInvalidte: Driver<ValidationResult>
    let sendEnabled: Driver<Bool>
    // Is signing process in progress
    let sending: Driver<Bool>
    let sendResult: Driver<ValidationResult>
    
    let doneEnabled: Driver<Bool>
    let doneResult: Driver<ValidationResult>
    
    
    init(
        input: (
        vcode: Driver<String>,
        sendTaps: Driver<Void>,
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
        let _ = dependency.wireframe
        
        let signingIn = ActivityIndicator()
        self.sending = signingIn.asDriver()
        
        self.sendEnabled = sending.distinctUntilChanged()
        
        vcodeInvalidte = input.vcode.map{vcode in
            return validation.validatePassword(vcode)
        }
        
        
        self.doneEnabled = Driver.combineLatest(
            vcodeInvalidte,
            sending) { vcode, sending in
                vcode.isValid &&
                !sending
            }
            .distinctUntilChanged()
        
        self.sendResult = input.sendTaps.withLatestFrom(vcodeInvalidte)
            .flatMapLatest({ (res) in
                return userManager.sendVcode(to: res.description)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "SignUp Success.")
                    }
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
        
        self.doneResult = input.doneTaps.withLatestFrom(vcodeInvalidte)
            .flatMapLatest({ (res) in
                return userManager.sendVcode(to: res.description)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "SignUp Success.")
                    }
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
        
    
    }
    
}

fileprivate func protectAccountErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.accountIsExist == _error {
        return Driver.just(ValidationResult.failed(message: "Account is exitsted"))
    }
    
    return Driver.just(ValidationResult.failed(message: ""))
}
