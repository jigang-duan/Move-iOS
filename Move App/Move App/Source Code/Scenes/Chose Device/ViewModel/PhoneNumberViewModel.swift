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
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    
    init(
        input: (
        phone: Driver<String>,
        nextTaps: Driver<Void>,
        info: DeviceBindInfo
        ),
        dependency: (
        validation: DefaultValidation,
        wireframe: Wireframe
        )
        ) {
      
        let validation = dependency.validation
        _ = dependency.wireframe
        
        
        phoneInvalidte = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        nextEnabled = phoneInvalidte.map({$0.isValid})
        
        nextResult = input.nextTaps.withLatestFrom(input.phone)
            .flatMapLatest({ phone in
                
                return DeviceManager.shared.checkBindPhone(deviceId: (input.info.deviceId)!, phone: phone)
                    .map({ type in
                        if type == -1 {
                            return ValidationResult.ok(message: "")
                        }else{
                            return ValidationResult.failed(message: R.string.localizable.id_phone_error_add())
                        }
                    })
                    .asDriver(onErrorJustReturn: ValidationResult.ok(message: ""))
            })

    }

}

