//
//  UpdatePswdViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional


class UpdatePswdViewModel {
    // outputs {
    
    //
    let validatedVcode: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    var validatedRePassword: Driver<ValidationResult>
    
    
    let sending: Driver<Bool>
    
    let sendEnabled: Driver<Bool>
    let sendResult: Driver<ValidationResult>
    
    
    let doneEnabled: Driver<Bool>
    let doneResult: Driver<ValidationResult>
    
    init(
        input: (
        sid: String,
        vcode: Driver<String>,
        passwd: Driver<String>,
        rePasswd: Driver<String>,
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
        
        validatedVcode = input.vcode
            .map { vcode in
                if vcode.characters.count > 0{
                    return ValidationResult.ok(message: "Vcode Avaliable")
                }
                return ValidationResult.empty
        }
        
        validatedPassword = input.passwd
            .map { password in
                return validation.validatePassword(password)
        }
        
        validatedRePassword = Driver.combineLatest(input.passwd, input.rePasswd){
            return validation.validateRePassword($0, rePasswd: $1)
        }
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        self.sendEnabled = Driver.just(true)
        
        self.doneEnabled = Driver.combineLatest(
            validatedVcode,
            validatedPassword,
            validatedRePassword,
            sending) { email, password, rePasswd, sending in
                email.isValid &&
                    password.isValid &&
                    rePasswd.isValid &&
                    !sending
            }
            .distinctUntilChanged()
        
        
        
        let email = userManager.getProfile().map{ $0.email }.asDriver(onErrorJustReturn: "")
        
        let sid = input.sendTaps.withLatestFrom(email)
            .flatMapLatest({ email in
                return userManager.sendVcode(to: email!)
                    .trackActivity(activity)
                    .map({$0.sid})
                    .filterNil()
                    .asDriver(onErrorJustReturn: "")
            })
        self.sendResult = sid.map({ ValidationResult.ok(message: $0) })
        
        let com = Driver.combineLatest(sid, input.vcode, email, input.passwd){ ($0, $1, $2, $3) }
        
        self.doneResult = input.doneTaps.withLatestFrom(com)
            .flatMapLatest({ (sid, vcode, email, password) in
                return userManager.updatePasssword(sid: sid, vcode: vcode, email: email!, password: password)
                    .trackActivity(activity)
                    .map { _ in
                        ValidationResult.ok(message: "Update Success.")
                    }
                    .asDriver(onErrorRecover: updatePswdErrorRecover)
            })
    }
    
}

fileprivate func updatePswdErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.accountNotFound == _error {
        return Driver.just(ValidationResult.failed(message: "Account not found"))
    }
    
    return Driver.just(ValidationResult.failed(message: ""))
}

