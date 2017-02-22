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
    let validatedRePassword: Driver<ValidationResult>
    

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
        
        validatedEmail = input.email
            .map { email in
                return validation.validateEmail(email)
        }
        
        validatedPassword = input.passwd
            .map { password in
                return validation.validatePassword(password)
        }
        
        validatedRePassword = input.rePasswd
            .map { rePasswd in
                var pd = ""
                _ = input.passwd.asObservable().map{
                    pd = $0
                    print($0)
                }
                return validation.validateRePassword(rePasswd, rePasswd: rePasswd)
        }
        
        let signingIn = ActivityIndicator()
        self.signUping = signingIn.asDriver()
        
        let emailAndPassword = Driver.combineLatest(input.email, input.passwd) { ($0, $1) }
        
        self.signUped = input.signUpTaps.withLatestFrom(emailAndPassword)
            .flatMapLatest({ (email, password) in
                return userManager.signUp(email: email, password: password)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "SignUp Success.")
                    }
                    .asDriver(onErrorRecover: signUpErrorRecover)
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

fileprivate func signUpErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.accountIsExist == _error {
        return Driver.just(ValidationResult.failed(message: "Account is exitsted"))
    }
    
    return Driver.just(ValidationResult.failed(message: ""))
}

