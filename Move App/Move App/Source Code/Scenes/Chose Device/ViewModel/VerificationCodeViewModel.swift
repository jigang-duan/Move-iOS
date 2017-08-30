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
    var firstEnter: Driver<ValidationResult>?
    
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
        
        firstEnter = userManager.sendVcode(to: input.imei).map({[weak self] sid in
            self?.sid = sid.sid
            return ValidationResult.ok(message: "Send Success")
        }).asDriver(onErrorRecover: errorRecover)
     
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: input.imei)
                    .map({info in
                        self.sid = info.sid
                        return  ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: errorRecover)
            })
        
        
        self.sendEnabled = Driver.of(firstEnter!, sendResult!).merge().map{ !$0.isValid }
        
        
        self.nextResult = input.nextTaps.withLatestFrom(input.vcode)
            .flatMapLatest({ (vcode) in
                return userManager.checkVcode(sid: self.sid!, vcode: vcode, from: input.imei)
                    .map { _ in
                        ValidationResult.ok(message: "Verify Success.")
                    }
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
    }
    
}

fileprivate func errorRecover(_ error: Swift.Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if case WorkerError.webApi(let id, _, let msg) = _error {
        if id == 6 && msg == "Not found" {
            return Driver.just(ValidationResult.failed(message: R.string.localizable.id_connect_watch()))
        }
    }
    
    return commonErrorRecover(error)
}
