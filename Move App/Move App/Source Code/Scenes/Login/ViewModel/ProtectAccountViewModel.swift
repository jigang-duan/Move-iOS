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
import RxOptional


class ProtectAccountViewModel {
    
    let vcodeInvalidte: Driver<ValidationResult>
    let sendEnabled: Driver<Bool>
    // Is signing process in progress
    let sending: Driver<Bool>
    var sendResult: Driver<ValidationResult>?
    
    let doneEnabled: Driver<Bool>
    var doneResult: Driver<ValidationResult>?
    
    var email: String?
    var sid: String?
    
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
        _ = dependency.validation
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        self.sendEnabled = Driver.just(true)
        
        vcodeInvalidte = input.vcode.map{vcode in
            if vcode.characters.count > 0{
                return ValidationResult.ok(message: "Vcode avaliable")
            }
            return ValidationResult.empty
        }
        
        
        self.doneEnabled = Driver.combineLatest(
            vcodeInvalidte,
            sending) { vcode, sending in
                vcode.isValid &&
                !sending
            }
            .distinctUntilChanged()
        
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: self.email!)
                    .map({info in
                        self.sid = info.sid
                        return ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
        

        self.doneResult = input.doneTaps.withLatestFrom(input.vcode)
            .flatMapLatest({ (vcode) in
                return userManager.checkVcode(sid: self.sid!, vcode: vcode)
                    .trackActivity(activity)
                    .map { _ in
                        ValidationResult.ok(message: "Verify Success.")
                    }
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
    }
    
}

fileprivate func protectAccountErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.vcodeIsIncorrect == _error {
        return Driver.just(ValidationResult.failed(message: "Vcode is Incorrect"))
    }
    
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}
