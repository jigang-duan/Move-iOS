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
    
    let downEnabled: Driver<Bool>
    let downResult: Driver<ValidationResult>
    
    
    init(
        input: (
            enter: Driver<Int>,
            downloadProgress: Driver<Int>,
            downloadTaps: Driver<Void>
        ),
        dependency: (
            deviceManager: DeviceManager,
            wireframe: Wireframe
        )
        ) {
        
        
        let deviceManager = dependency.deviceManager
        _ = dependency.wireframe
        
        
        downEnabled = input.downloadProgress.map({ p in
            return p <= 0 || p >= 100
        })
        
        
        
        downResult = input.downloadTaps.flatMapLatest({ _ in
             deviceManager.sendNotify(deviceId: (deviceManager.currentDevice?.deviceId)!, code: DeviceNotify.downloadFirmware)
                .map{ _ in
                    return ValidationResult.ok(message: "Download Begin")
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
