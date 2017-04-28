//
//  AccountAndChoseDeviceViewModel.swift
//  Move App
//
//  Created by Vernon yellow on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AccountAndChoseDeviceViewModel {
    // outputs {
    
    let head: Driver<String>
    let accountName: Driver<String>
    
    let selected: Driver<String>
    
    let fetchDevices: Driver<[DeviceInfo]>
    let devicesVariable: Variable<[DeviceInfo]> = RxStore.shared.deviceInfosState
    
    init (input: (
        enter: Driver<Bool>,
        selectedInext: Driver<Int>
        ),
        dependency: (
        userManager: UserManager,
        deviceManager: DeviceManager,
        wireframe: Wireframe
        )
        ) {
        
        let userManger = dependency.userManager
        let deviceManager = dependency.deviceManager
        let _ = dependency.wireframe
        
        let enter = input.enter.filter({ $0 })
        
        self.accountName = enter.flatMapLatest { _ in userManger.getProfile().map{ $0.nickname ?? "" }.asDriver(onErrorJustReturn: "") }
        
        self.head = enter
            .flatMapLatest { _ in
                userManger.getProfile()
                    .map { $0.iconUrl ?? "" }
                    .asDriver(onErrorJustReturn: "")
            }
        
        self.fetchDevices = enter.flatMapLatest({ _ in deviceManager.fetchDevices().asDriver(onErrorJustReturn: []) })
        
        self.selected = input.selectedInext
            .withLatestFrom(devicesVariable.asDriver()) { $1[$0] }
            .map { $0.deviceId }
            .filterNil()
        
    }
    
}





