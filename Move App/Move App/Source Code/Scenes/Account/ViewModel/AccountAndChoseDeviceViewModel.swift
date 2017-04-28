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
    
    let profile: Driver<UserInfo.Profile>
    let accountName: Driver<String>
    
    let fetchDevices: Driver<[DeviceInfo]>
    
    init (input: (
        enter: Driver<Bool>,
        empty: Void
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
        
        let enter = input.enter.filter{ $0 }
        
        self.profile = enter.flatMapLatest { (_) in userManger.getProfile().asDriver(onErrorJustReturn: UserInfo.Profile()) }
        self.accountName = profile.map { $0.nickname ?? "" }
        
        self.fetchDevices = enter.flatMapLatest({ _ in deviceManager.fetchDevices().asDriver(onErrorJustReturn: []) })
        
    }
    
}





