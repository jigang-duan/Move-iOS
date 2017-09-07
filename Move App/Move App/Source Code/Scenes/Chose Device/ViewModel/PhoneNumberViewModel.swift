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
        phonePrefix: Driver<String>,
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
        
        
        let prefixAndPhone = Driver.combineLatest(input.phonePrefix, input.phone){($0, $1)}
        
        nextResult = input.nextTaps.withLatestFrom(prefixAndPhone)
            .flatMapLatest({ (prefix, phone) in
                
                var checkPhone = ""
                
                if prefix == "" || prefix == "-" {
                    checkPhone = phone
                }else{
                    checkPhone = "\(prefix)@\(phone)"
                }
                
                return DeviceManager.shared.checkBindPhone(deviceId: (input.info.deviceId)!, phone: checkPhone)
                    .flatMapLatest({ type -> Observable<ValidationResult> in
//                        联系人类型
//                        -1 - 未添加该号码
//                        0 - 非注册用户
//                        1 - 注册用户
//                        2 - 注册设备
                        if type == -1 {
                            return Observable.just(ValidationResult.ok(message: ""))
                        }else if type == 0 {
                            return DeviceManager.shared.joinGroup(joinInfo: input.info)
                                .map({_ in
                                    return  ValidationResult.ok(message: "join")
                                })
                        }else{
                            return Observable.just(ValidationResult.failed(message: R.string.localizable.id_phone_error_add()))
                        }
                    })
                    .asDriver(onErrorJustReturn: ValidationResult.ok(message: ""))
            })

    }

}

