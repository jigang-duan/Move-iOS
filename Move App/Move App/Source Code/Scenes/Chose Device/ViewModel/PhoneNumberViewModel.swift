//
//  PhoneNumberViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/28.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class PhoneNumberViewModel {
    
    let phoneInvalidte: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    var info: DeviceBindInfo?
    
    var phoneSuffix: String? {
        get{
            return info?.phone?.substring(from: (info?.phone?.index((info?.phone?.endIndex)!, offsetBy: -4))!)
        }
    }
    
    init(
        input: (
        forCheckNumber: Bool,
        phone: Driver<String>,
        nextTaps: Driver<Void>
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
        
//        let activity = ActivityIndicator()
        self.sending = Driver.just(false)
        
        
        phoneInvalidte = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        
        nextEnabled = Driver.combineLatest(
            phoneInvalidte,
            sending) { phone, sending in
                phone.isValid && !sending
            }
            .distinctUntilChanged()
        
        
        
        if input.forCheckNumber == true {
            nextResult = input.nextTaps.withLatestFrom(input.phone)
                .flatMapLatest({ phone in
                    if phone != self.phoneSuffix {
                        return Driver.just(ValidationResult.failed(message: "Your number can't match"))
                    }
                    
                    return deviceManager.joinGroup(joinInfo: self.info!).map({_ in
                        return ValidationResult.ok(message: "Send Success.")
                    }).asDriver(onErrorRecover: commonErrorRecover)
                })
        }else{
            nextResult = input.nextTaps
                .flatMapLatest({ _ in
                    return  Driver.just(ValidationResult.ok(message: "Send Success."))
                })
        }
        
        
        
    }
    
}

