//
//  MeLogoutViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class MeLogoutViewModel {
    
    let sending: Driver<Bool>
    
    let logoutEnabled: Driver<Bool>
    let logoutResult: Driver<ValidationResult>
    
    
    init(
        input: Driver<Void>,
        dependency: (
        userManager: UserManager,
        wireframe: DefaultWireframe
        )
        ) {
        
        let userManager = dependency.userManager
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        logoutEnabled = sending.map({ send in
            return !send
        })
        
        
        logoutResult = input.flatMapLatest({_ in
                return userManager.logout()
                    .trackActivity(activity)
                    .map { _ in
                        return ValidationResult.ok(message: "Logout Success.")
                    }
                    .asDriver(onErrorRecover: errorRecover)
            })
        
    }
    
}

fileprivate func errorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Logout failed."))
}

