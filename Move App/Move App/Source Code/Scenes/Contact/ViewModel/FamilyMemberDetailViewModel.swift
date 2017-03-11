//
//  FamilyMemberDetailViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class FamilyMemberDetailViewModel {
    
    var nameInvalidte: Driver<ValidationResult>?
    var phoneInvalidte: Driver<ValidationResult>?
    
    
    var saveEnabled: Driver<Bool>?
    var saveResult: Driver<ValidationResult>?
    
    var masterResult: Driver<ValidationResult>?
    var deleteResult: Driver<ValidationResult>?
    
    var contactInfo: Variable<ImContact>?
    
    init(
        input:(
        name: Driver<String>,
        number: Driver<String>,
        masterTaps: Driver<Void>,
        deleteTaps: Driver<Void>,
        saveTaps: Driver<Void>
        ),
        dependency: (
        deviceManager: DeviceManager,
        validation: DefaultValidation,
        wireframe: DefaultWireframe
        )
        ) {
        
        let deviceManager = dependency.deviceManager
        _ = dependency.validation
        _ = dependency.wireframe
        
        nameInvalidte = input.name.map{name in
            self.contactInfo?.value.nickname = name
            if name.characters.count > 0{
                return ValidationResult.ok(message: "name avaliable")
            }
            return ValidationResult.empty
        }
        
        phoneInvalidte = input.number.map{number in
            self.contactInfo?.value.phone = number
            if number.characters.count > 0{
                return ValidationResult.ok(message: "number avaliable")
            }
            return ValidationResult.empty
        }
        
        
        self.saveEnabled = Driver.combineLatest( nameInvalidte!, phoneInvalidte!) { name, phone in
            name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        masterResult = input.masterTaps
            .flatMapLatest({ _ in
                var info = self.contactInfo?.value
                info?.flag = 0x100
                return deviceManager.settingContactInfo(deviceId: (deviceManager.currentDevice?.deviceId)!, contactInfo: info!).map({ _ in
                    return ValidationResult.ok(message: "Set Success.")
                }).asDriver(onErrorRecover: errorRecover)
            })
        
        deleteResult = input.deleteTaps
            .flatMapLatest({ _ in
                return deviceManager.deleteContact(deviceId: (deviceManager.currentDevice?.deviceId)!, uid: (self.contactInfo?.value.uid)!).map({ _ in
                    return ValidationResult.ok(message: "Delete Success.")
                }).asDriver(onErrorRecover: errorRecover)
            })
        
        saveResult = input.saveTaps
            .flatMapLatest({ _ in
                return deviceManager.settingContactInfo(deviceId: (deviceManager.currentDevice?.deviceId)!, contactInfo: (self.contactInfo?.value)!).map({ _ in
                    return ValidationResult.ok(message: "Set Success.")
                }).asDriver(onErrorRecover: errorRecover)
            })
        
    }
    
}

fileprivate func errorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.vcodeIsIncorrect == _error {
        return Driver.just(ValidationResult.failed(message: "Vcode is Incorrect"))
    }
    
    
    return Driver.just(ValidationResult.failed(message: "Set faild"))
}


