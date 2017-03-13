//
//  DistributionViewModel.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class DistributionViewModel {
    // outputs {
    
    //
    let enterLogin: Driver<Bool>
    let enterMain: Driver<Bool>
    let enterChoose: Driver<Bool>
    
    // }
    
    init(
        dependency: (
        meManager: MeManager,
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let meManager = dependency.meManager
        let userManager = dependency.userManager
        
        let delay = Observable.just(1).delay(5, scheduler: MainScheduler.instance)
        
        self.enterLogin =  delay
            .flatMap { _ in
                userManager.isValid()
                    .map { !$0 }
            }
            .asDriver(onErrorJustReturn: true)
        
        let hasRole = enterLogin
            .filter({ !$0 })
            .flatMap ({_ in
                meManager.checkCurrentRole()
                    .map {
                        $0 != nil
                    }
                    .asDriver(onErrorJustReturn: false)
            })
        
        self.enterChoose = Driver.combineLatest(
            enterLogin,
            hasRole) { enterLogin, hasRole in
                !enterLogin && !hasRole
            }
        
        self.enterMain = self.enterChoose.map {!$0}
    }
}
