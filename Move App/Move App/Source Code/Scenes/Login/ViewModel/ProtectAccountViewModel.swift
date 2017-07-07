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
    
    var sendEnabled: Driver<Bool>?

    var sending: Driver<Bool>?
    var sendResult: Driver<ValidationResult>?
    
    var doneEnabled: Driver<Bool>?
    var doneResult: Driver<ValidationResult>?
    
    var sid: String? = nil
    
    init(
        input: (
        registerInfo: MoveApi.RegisterInfo,
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
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        let vcodeInvalidte = input.vcode.map{vcode in
            return validation.validateVCode(vcode)
        }
        
        let firstEnter = userManager.sendVcode(to: (input.registerInfo.email)!).map({[weak self] sid in
            self?.sid = sid.sid
            return ValidationResult.ok(message: "Send Success")
        }).asDriver(onErrorRecover: commonErrorRecover)
        
        
        let vcodeNotEmpty = input.vcode.map{vcode in
            return vcode.characters.count > 0
        }
        
        self.doneEnabled = Driver.combineLatest(vcodeNotEmpty,sending!) { vcode, sending in
                vcode && !sending
            }
            .distinctUntilChanged()
        
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: input.registerInfo.email!)
                    .map({info in
                        self.sid = info.sid
                        return ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: commonErrorRecover)
            })
        
        
        self.sendEnabled = Driver.of(firstEnter, sendResult!).merge().map{ !$0.isValid }

        
        let com = Driver.combineLatest(vcodeInvalidte, input.vcode){($0,$1)}
        
        self.doneResult = input.doneTaps.withLatestFrom(com)
            .flatMapLatest({ res, vcode in
                if res.isValid {
                    return userManager.signUp(username: input.registerInfo.email!, password: input.registerInfo.password!, sid: self.sid!, vcode: vcode)
                        .trackActivity(activity)
                        .map { _ in
                            ValidationResult.ok(message: "SignUp Success.")
                        }
                        .asDriver(onErrorRecover: commonErrorRecover)
                }else{
                    return Driver.just(res)
                }
            })
    }
    
}

