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
    
    let sending: Driver<Bool>
    
    let confirmEnabled: Driver<Bool>
    var confirmResult: Driver<ValidationResult>?
    
    var sid: String?
    
    init(
        input: (
        imei: Driver<String>,
        confirmTaps: Driver<Void>
        ),
        dependency: (
        userManager: UserManager,
        deviceManager: DeviceManager,
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
        
        let userManager = dependency.userManager
        let deviceManager = dependency.deviceManager
        _ = dependency.validation
        _ = dependency.wireframe
       
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        imeiInvalidte = input.imei
            .map {  imei in
                if imei.characters.count > 0{
                    return ValidationResult.ok(message: "")
                }
                return ValidationResult.empty
        }
        
        
        self.confirmEnabled = Driver.combineLatest(
            imeiInvalidte,
            sending) { imei, sending in
                imei.isValid &&
                    !sending
            }
            .distinctUntilChanged()
    
        
        
   
        
        self.confirmResult = input.confirmTaps.withLatestFrom(input.imei)
            .flatMapLatest({ imei in
                return deviceManager.checkBind(deviceId: imei).map({ event in
                    if event == false {
                        _ = userManager.sendVcode(to: imei)
                            .trackActivity(activity)
                            .map({info in
                            self.sid = info.sid
                                return ValidationResult.ok(message: "Send Success.")
                            }).asDriver(onErrorRecover: inputIMEIErrorRecover)
                    }
                    return ValidationResult.failed(message: "The watch has been paired by others,please contact this watch's master to share QR code with you.")
                }).asDriver(onErrorRecover: checkIMEIErrorRecover)

                
               
            })
        
    }
    
}

fileprivate func inputIMEIErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}

fileprivate func checkIMEIErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    return Driver.just(ValidationResult.failed(message: "check failed"))
}




