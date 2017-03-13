//
//  VerificationCodeViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional


class VerificationCodeViewModel {
    
    let vcodeInvalidte: Driver<ValidationResult>
    var sendEnabled: Driver<Bool>?

    let sending: Driver<Bool>
    var sendResult: Driver<ValidationResult>?
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    var sid: String?
    
    init(
        input: (
        imei: String,
        vcode: Driver<String>,
        sendTaps: Driver<Void>,
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
        
        
        vcodeInvalidte = input.vcode.map{vcode in
            if vcode.characters.count > 0{
                return ValidationResult.ok(message: "Vcode avaliable")
            }
            return ValidationResult.empty
        }
        
        
        self.nextEnabled = Driver.combineLatest(
            vcodeInvalidte,
            sending) { vcode, sending in
                vcode.isValid &&
                    !sending
            }
            .distinctUntilChanged()
        
        let firstEnter = userManager.sendVcode(to: input.imei).map({[weak self] sid in
            self?.sid = sid.sid
            return ValidationResult.ok(message: "Send Success")
        }).asDriver(onErrorRecover: protectAccountErrorRecover)
     
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: input.imei)
                    .map({info in
                        self.sid = info.sid
                        return  ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
        
        
        self.sendEnabled = Driver.of(firstEnter, sendResult!).merge().map{ !$0.isValid }
        
        
        self.nextResult = input.nextTaps.withLatestFrom(input.vcode)
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

