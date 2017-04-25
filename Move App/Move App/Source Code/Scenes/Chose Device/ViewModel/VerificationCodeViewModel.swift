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
        let validation = dependency.validation
        _ = dependency.wireframe
        
        vcodeInvalidte = input.vcode.map{vcode in
            return validation.validateVCode(vcode)
        }
        
        self.nextEnabled = vcodeInvalidte.map({$0.isValid})
        
        let firstEnter = userManager.sendVcode(to: input.imei).map({[weak self] sid in
            self?.sid = sid.sid
            return ValidationResult.ok(message: "Send Success")
        }).asDriver(onErrorRecover: commonErrorRecover)
     
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: input.imei)
                    .map({info in
                        self.sid = info.sid
                        return  ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
        
        
        self.sendEnabled = Driver.of(firstEnter, sendResult!).merge().map{ !$0.isValid }
        
        
        self.nextResult = input.nextTaps.withLatestFrom(input.vcode)
            .flatMapLatest({ (vcode) in
                return userManager.checkVcode(sid: self.sid!, vcode: vcode)
                    .map { _ in
                        ValidationResult.ok(message: "Verify Success.")
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
    }
    
}

