//
//  UpgradeViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UpgradeViewModel {
    
    let downResult: Driver<ValidationResult>
    
    
    init(
        input: (
            enter: Driver<Int>,
            downloadTaps: Driver<Void>
        ),
        dependency: (
            deviceManager: DeviceManager,
            wireframe: Wireframe
        )
        ) {
        
        
        let deviceManager = dependency.deviceManager
        _ = dependency.wireframe
        
        
        downResult = input.downloadTaps.flatMapLatest({ _ in
             deviceManager.sendNotify(deviceId: (deviceManager.currentDevice?.deviceId)!, code: DeviceNotify.downloadFirmware)
                .map{ _ in
                    return ValidationResult.ok(message: "Download Begin")
                }
                .asDriver(onErrorRecover: commonErrorRecover)
        })
        
        
    }
    
 
}

