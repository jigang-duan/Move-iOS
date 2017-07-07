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
        
        
        let validatedName = input.name.map { name in
            return validation.validateNickName(name)
        }
        
        let nameNotEmpty = input.name.map { name in
            return name.characters.count > 0
        }
    
        saveEnabled = Driver.combineLatest(nameNotEmpty,sending) { name, sending in
                name && !sending
            }
            .distinctUntilChanged()
        
        
        let com = Driver.combineLatest(validatedName, input.name){($0,$1)}
        
        saveResult = input.saveTaps.withLatestFrom(com)
            .flatMapLatest({res, name in
                if res.isValid {
                    var info = UserInfo.Profile()
                    info.nickname = name
                    return userManager.setUserInfo(userInfo: info)
                        .trackActivity(activity)
                        .map { _ in
                            UserInfo.shared.profile?.nickname = name
                            return ValidationResult.ok(message: "Set Success.")
                        }
                        .asDriver(onErrorRecover: commonErrorRecover)
                }else{
                    return Driver.just(res)
                }
            })
        
    }
    
}



