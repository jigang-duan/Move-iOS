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
        
        
        phoneInvalidte = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        nextEnabled = phoneInvalidte.map({$0.isValid})
        
        if input.forCheckNumber == true {
            nextResult = input.nextTaps.withLatestFrom(input.phone)
                .flatMapLatest({ phone in
                    if phone != self.phoneSuffix {
                        return Driver.just(ValidationResult.failed(message: "Your number can't match"))
                    }
                    
                    return deviceManager.joinGroup(joinInfo: self.info!).map({_ in
                        return ValidationResult.ok(message: "Send Success.")
                    }).asDriver(onErrorRecover: errorRecover)
                })
        }else{
            nextResult = input.nextTaps
                .flatMapLatest({ _ in
                    return  Driver.just(ValidationResult.ok(message: "Send Success."))
                })
        }
        
        
        
    }
    
}


fileprivate func errorRecover(_ error: Error) -> Driver<ValidationResult>  {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.webApi(id: 7, field: "uid", msg: "Exists") == _error {
        return Driver.just(ValidationResult.failed(message: "This watch is existed"))
    }
    
    let msg = WorkerError.apiErrorTransform(from: _error)
    return Driver.just(ValidationResult.failed(message: msg))
}


