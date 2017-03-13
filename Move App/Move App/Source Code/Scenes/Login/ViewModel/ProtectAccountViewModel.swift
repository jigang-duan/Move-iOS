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
    
    var vcodeInvalidte: Driver<ValidationResult>?
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
        
        let firstEnter = userManager.sendVcode(to: (input.registerInfo.email)!).map({[weak self] sid in
            self?.sid = sid.sid
            return ValidationResult.ok(message: "Send Success")
        }).asDriver(onErrorRecover: protectAccountErrorRecover)
        
        
        self.doneEnabled = Driver.combineLatest(
            vcodeInvalidte!,
            sending!) { vcode, sending in
                vcode.isValid &&
                !sending
            }
            .distinctUntilChanged()
        
        self.sendResult = input.sendTaps
            .flatMapLatest({ _ in
                return userManager.sendVcode(to: input.registerInfo.email!)
                    .map({info in
                        self.sid = info.sid
                        return ValidationResult.ok(message: "Send Success")
                    })
                    .asDriver(onErrorRecover: protectAccountErrorRecover)
            })
        
        
        self.sendEnabled = Driver.of(firstEnter, sendResult!).merge().map{ !$0.isValid }

        self.doneResult = input.doneTaps.withLatestFrom(input.vcode)
            .flatMapLatest({ (vcode) in
                return userManager.signUp(username: input.registerInfo.email!, password: input.registerInfo.password!, sid: self.sid!, vcode: vcode)
                    .trackActivity(activity)
                    .map { _ in
                        ValidationResult.ok(message: "SignUp Success.")
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
