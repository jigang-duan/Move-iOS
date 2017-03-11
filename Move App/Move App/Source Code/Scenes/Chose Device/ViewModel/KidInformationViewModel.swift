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
    
    let nameValid: Driver<ValidationResult>
    let phoneValid: Driver<ValidationResult>
    
    
    let sending: Driver<Bool>
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    var addInfo: DeviceBindInfo?
    
    var isForSetting: Variable<Bool>?
    
    init(
        input: (
        name: Driver<String>,
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
        
        let activity = ActivityIndicator()
        self.sending = activity.asDriver()
        
        
        nameValid = input.name.map { name in
            if name.characters.count > 0{
                return ValidationResult.ok(message: "")
            }
            return ValidationResult.empty
        }
        
        phoneValid = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        
        nextEnabled = Driver.combineLatest(nameValid, phoneValid, sending) { name, phone, sending in
                name.isValid && phone.isValid && !sending
            }
            .distinctUntilChanged()
        
        let com = Driver.combineLatest(input.name, input.phone){($0, $1)}
        
        self.nextResult = input.nextTaps.withLatestFrom(com)
            .flatMapLatest({ name, phone in
                if (self.isForSetting?.value)! == true {
                    let f = self.addInfo!
                    return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: "", number: phone, nickname: name, profile: f.profile, gender: f.gender, height: f.height, weight: f.weight, birthday: f.birthday))
                        .map({_ in
                            var user = DeviceManager.shared.currentDevice?.user
                            user?.number = phone
                            user?.nickname = name
                            user?.profile = f.profile
                            user?.gender = f.gender
                            user?.height = f.height
                            user?.weight = f.weight
                            user?.birthday = f.birthday
                            DeviceManager.shared.currentDevice?.user = user
                            
                            return  ValidationResult.ok(message: "Update Success")
                        })
                        .asDriver(onErrorRecover: kidInformationErrorRecover)
                }else{
                    return deviceManager.addDevice(firstBindInfo: self.addInfo!)
                        .map({_ in
                            return  ValidationResult.ok(message: "Bind Success")
                        })
                        .asDriver(onErrorRecover: kidInformationErrorRecover)
                }
            })
        
    }
    
}

fileprivate func kidInformationErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard error is WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}

