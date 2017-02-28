//
//  IputIMEIViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class InputIMEIViewModel {
    
    let imeiInvalidte: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let confirmEnabled: Driver<Bool>
    var confirmResult: Driver<ValidationResult>?
    
    var sid: String?
    
    init(
        input: (
        imei: Driver<String>,
        confirmTaps: Driver<Void>
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
        
        
        imeiInvalidte = input.imei
            .map {  imei in
                if imei.characters.count > 0{
                    return ValidationResult.ok(message: "")
                }
                return ValidationResult.empty
        }
        
        
        self.confirmEnabled = Driver.combineLatest(
            imeiInvalidte,
            sending) { imei, sending in
                imei.isValid &&
                    !sending
            }
            .distinctUntilChanged()
        
        
        let email = userManager.getProfile().map({$0.email}).filterNil().asDriver(onErrorJustReturn: "")
        
        self.confirmResult = input.confirmTaps.withLatestFrom(email)
            .flatMapLatest({ email in
                return userManager.sendVcode(to: email)
                    .trackActivity(activity)
                    .map({info in
                        self.sid = info.sid
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

