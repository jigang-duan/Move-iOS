//
//  IputIMEIViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/27.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class InputIMEIViewModel {
    
    let imeiInvalidte: Driver<ValidationResult>
    
    
    let confirmEnabled: Driver<Bool>
    var confirmResult: Driver<ValidationResult>?
    
    init(
        input: (
        imei: Driver<String>,
        confirmTaps: Driver<Void>
        ),
        dependency: (
        deviceManager: DeviceManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let deviceManager = dependency.deviceManager
        let validation = dependency.validation
        _ = dependency.wireframe
        
        imeiInvalidte = input.imei.map{ imei in
            return validation.validateIMEI(imei)
        }
        
        self.confirmEnabled = imeiInvalidte.map({$0.isValid})
        
        self.confirmResult = input.confirmTaps.withLatestFrom(input.imei)
            .flatMapLatest({ imei in
                return deviceManager.checkBind(deviceId: imei).map({ bind in
                    if bind == false {
                        return ValidationResult.ok(message: "check Success.")
                    }else {
                        return ValidationResult.failed(message: "The watch has been paired by others,please contact this watch's master to share QR code with you.")
                    }
                }).asDriver(onErrorRecover: commonErrorRecover)

                
               
            })
        
    }
    
}



