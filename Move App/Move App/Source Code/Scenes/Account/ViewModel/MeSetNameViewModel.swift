//
//  MeSetNameViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MeSetNameViewModel {
    
    let validatedName: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let saveEnabled: Driver<Bool>
    let saveResult: Driver<ValidationResult>
    
    
    init(
        input:(
        name: Driver<String>,
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
        
        
        validatedName = input.name.map { name in
            return validation.validateAccount(name)
        }
        
    
        saveEnabled = Driver.combineLatest(
            validatedName,
            sending) { name, sending in
                name.isValid && !sending
            }
            .distinctUntilChanged()
        
        
        saveResult = input.saveTaps.withLatestFrom(input.name)
            .flatMapLatest({name in
                var info = UserInfo.Profile()
                info.nickname = name
                return userManager.setUserInfo(userInfo: info)
                    .trackActivity(activity)
                    .map { _ in
                        UserInfo.shared.profile?.nickname = name
                        return ValidationResult.ok(message: "Set Success.")
                    }
                    .asDriver(onErrorRecover: meSetNameErrorRecover)
            })
        
    }
    
}

fileprivate func meSetNameErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Set faild"))
}


