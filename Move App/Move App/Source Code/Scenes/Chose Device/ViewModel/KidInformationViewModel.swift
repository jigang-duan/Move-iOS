//
//  KidInformationViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class KidInformationViewModel {
    
    let sending: Driver<Bool>
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    var addInfo: DeviceBindInfo?
    
    init(
        input: (
        Driver<Void>
        ),
        dependency: (
        deviceManager: DeviceManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let deviceManager = dependency.deviceManager
        _ = dependency.validation
        _ = dependency.wireframe
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        
        self.nextEnabled = Driver.just(true)
        
        
        self.nextResult = input
            .flatMapLatest({ _ in
                return deviceManager.addDevice(firstBindInfo: self.addInfo!)
                    .map({_ in
                        return  ValidationResult.ok(message: "Bind Success")
                    })
                    .asDriver(onErrorRecover: kidInformationErrorRecover)
            })
        
    }
    
}

fileprivate func kidInformationErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}

