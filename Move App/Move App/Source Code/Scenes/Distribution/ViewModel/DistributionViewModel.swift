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
    //let enterMain: Driver<Bool>
    //let enterChoose: Driver<Bool>
    
    let fetchDevices: Driver<[DeviceInfo]>
    let deviceId: Driver<String>
    
    // }
    
    init(
        dependency: (
        deviceManager: DeviceManager,
        userManager: UserManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let userManager = dependency.userManager
        let deviceManger = dependency.deviceManager
        
        let delay = Observable.just(1).delay(3, scheduler: MainScheduler.instance).share()
        
        self.enterLogin =  delay
            .flatMap { _ in userManager.isValid().map { !$0 } }
            .asDriver(onErrorJustReturn: true)
        
        self.fetchDevices = enterLogin
            .filter({ !$0 })
            .flatMapLatest { _ in deviceManger.fetchDevices().asDriver(onErrorJustReturn: []) }
        
        self.deviceId = fetchDevices.map({ $0.first?.deviceId }).filterNil()
    }
}
