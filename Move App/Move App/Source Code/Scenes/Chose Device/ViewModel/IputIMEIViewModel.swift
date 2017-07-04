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
                return deviceManager.getContacts(deviceId: imei).map({cons in
                            let flag = cons.map({$0.uid}).contains(where: { uid -> Bool in
                                return uid == UserInfo.shared.id
                            })
                            if flag == true {
                                return ValidationResult.ok(message: R.string.localizable.id_watch_existed())
                            }else{
                                return ValidationResult.failed(message: "")
                            }
                        })
                        .asDriver(onErrorRecover: commonErrorRecover)
            })
            .withLatestFrom(input.imei, resultSelector: {($0, $1)})
            .flatMapLatest({result, imei in
                if case ValidationResult.ok(let msg) = result {
                    return Driver.just(ValidationResult.failed(message: msg))
                }else{
                    return deviceManager.checkBind(deviceId: imei).map({ bind in
                                if bind == false {
                                    return ValidationResult.ok(message: "check Success.")
                                }else {
                                    return ValidationResult.failed(message: R.string.localizable.id_device_isbind())
                                }
                            })
                            .asDriver(onErrorRecover: commonErrorRecover)
                }
            })
        
    }
    
}



