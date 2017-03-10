//
//  MeSetPasswordViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MeSetPasswordViewModel {
    
    let validatedOld: Driver<ValidationResult>
    let validatedNew: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let saveEnabled: Driver<Bool>
    let saveResult: Driver<ValidationResult>
    
    
    init(
        input:(
        old: Driver<String>,
        new: Driver<String>,
        saveTaps: Driver<Void>
        ),
        dependency: (
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: DefaultWireframe
        )
        ) {
        
        let userManager = dependency.userManager
        let validation = dependency.validation
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        validatedOld = input.old.map { old in
            return validation.validatePassword(old)
        }
        
        validatedNew = input.new.map { new in
            return validation.validatePassword(new)
        }
        
        saveEnabled = Driver.combineLatest(validatedOld, validatedNew, sending) { old, new, sending in
                old.isValid && new.isValid && !sending
            }
            .distinctUntilChanged()
        
        let com = Driver.combineLatest(input.old, input.new){ ($0, $1) }
        
        saveResult = input.saveTaps.withLatestFrom(com)
            .flatMapLatest({old, new in
                var info = UserInfo.Profile()
                info.password = old
                return userManager.setUserInfo(userInfo: info, newPassword: new)
                    .trackActivity(activity)
                    .map { _ in
                        ValidationResult.ok(message: "Set Success.")
                    }
                    .asDriver(onErrorRecover: errorRecover)
            })
        
    }
    
}

fileprivate func errorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Set faild"))
}

