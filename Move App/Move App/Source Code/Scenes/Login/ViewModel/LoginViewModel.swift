//
//  LoginViewModel.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class LoginViewModel {
    // outputs {
    
    //
    let validatedEmail: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    
    // Is login button enabled
    let loginEnabled: Driver<Bool>
    
    // Has user signed in
    let logedIn: Driver<ValidationResult>
    
    // Is signing process in progress
    let loggingIn: Driver<Bool>
    
    let thirdLoginResult: Driver<ValidationResult>
    
    init(
        input: (
        email: Driver<String>,
        passwd: Driver<String>,
        loginTaps: Driver<Void>,
        thirdLogin: Driver<(MoveApiUserWorker.LoginType,String,String)>
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
            .map { validation.validateEmail($0) }
        
        validatedPassword = input.passwd
            .map { validation.validatePassword($0) }
        
        let signingIn = ActivityIndicator()
        self.loggingIn = signingIn.asDriver()
        
        let emailAndPassword = Driver.combineLatest(input.email, input.passwd) { ($0, $1) }
        
        self.logedIn = input.loginTaps.withLatestFrom(emailAndPassword)
            .flatMapLatest({ (email, password) in
                return userManager.login(email: email, password: password)
                    .trackActivity(signingIn)
                    .map { _ in
                        ValidationResult.ok(message: "Login Success.")
                    }
                    .asDriver(onErrorRecover: loginErrorRecover)
            })
        
        self.loginEnabled = Driver.combineLatest(
            validatedEmail,
            validatedPassword,
            loggingIn) { email, password, loggingIn in
                email.isValid &&
                password.isValid &&
                !loggingIn
            }
            .distinctUntilChanged()
        
        
        let third = input.thirdLogin.filter({ $0.0 != MoveApiUserWorker.LoginType.none })
        
        self.thirdLoginResult = third.flatMapLatest({ info in
            return userManager.tplogin(platform: info.0, openld: info.1, secret: info.2)
                .trackActivity(signingIn)
                .map { _ in
                    ValidationResult.ok(message: "Login Success.")
                }
                .asDriver(onErrorRecover: loginErrorRecover)
        })
        
    }
    
}

fileprivate func loginErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.accountNotFound == _error {
        return Driver.just(ValidationResult.failed(message: "Account doesn’t exist."))
    }
    
    if WorkerError.password == _error {
        return Driver.just(ValidationResult.failed(message: "user or password error"))
    }
        
    return Driver.just(ValidationResult.failed(message: ""))
}
