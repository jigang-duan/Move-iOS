//
//  SignUpViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class SignUpViewModel {
    // outputs {
    
    //
    let validatedEmail: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    var validatedRePassword: Driver<ValidationResult>
    

    let signUpEnabled: Driver<Bool>
    // Is signing process in progress
    let signUping: Driver<Bool>
    
    let signUped: Driver<ValidationResult>

    
    init(
        input: (
            email: Driver<String>,
            passwd: Driver<String>,
            rePasswd: Driver<String>,
            signUpTaps: Driver<Void>
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
        
        validatedEmail = input.email.map(validation.validateEmail)
        
        validatedPassword = input.passwd.map(validation.validatePassword)
        
        validatedRePassword = Driver.combineLatest(input.passwd, input.rePasswd){
            return validation.validateRePassword($0, rePasswd: $1)
        }
        
        let signingIn = ActivityIndicator()
        self.signUping = signingIn.asDriver()
        
        self.signUped = input.signUpTaps.withLatestFrom(input.email)
            .flatMapLatest({ email in
                return userManager.isRegistered(account: email)
                    .trackActivity(signingIn)
                    .map { flag in
                        if flag == false{
                           return ValidationResult.ok(message: "Account avaliable")
                        }else{
                           return ValidationResult.failed(message: R.string.localizable.id_account_used())
                        }
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
        
        self.signUpEnabled = Driver.combineLatest(
            validatedEmail,
            validatedPassword,
            validatedRePassword,
            signUping) { email, password, rePasswd, signUping in
                email.isValid &&
                password.isValid &&
                rePasswd.isValid &&
                !signUping
            }
            .distinctUntilChanged()
    }
    
}

