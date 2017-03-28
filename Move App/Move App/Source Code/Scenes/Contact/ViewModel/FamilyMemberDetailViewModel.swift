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
        photo: Variable<UIImage?>,
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
        let validation = dependency.validation
        _ = dependency.wireframe
        
        
        nameInvalidte = input.name.map{name -> ValidationResult in
            self.contactInfo?.value.identity = Relation(input: name )
            if name.characters.count > 0{
                return ValidationResult.ok(message: "name avaliable")
            }
            return ValidationResult.empty
        }
        
        phoneInvalidte = input.number.map{number -> ValidationResult in
            self.contactInfo?.value.phone = number
            return validation.validatePhone(number)
        }
        
        
        self.saveEnabled = Driver.combineLatest( nameInvalidte!, phoneInvalidte!) { name, phone in
            name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        masterResult = input.masterTaps
            .flatMapLatest({ _ in
                let info = self.contactInfo?.value
                return deviceManager.settingAdmin(deviceId: (deviceManager.currentDevice?.deviceId)!, uid: (info?.uid)!).map({ _ in
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
                if let photo = input.photo.value {
                    return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil()
                        .flatMapLatest({ fid -> Observable<ValidationResult> in
                            var info = (self.contactInfo?.value)!
                            info.profile = fid
                            return deviceManager.settingContactInfo(deviceId: (deviceManager.currentDevice?.deviceId)!, contactInfo: info).map({ _ in
                                return ValidationResult.ok(message: "Set Success.")
                            })
                    }).asDriver(onErrorRecover: errorRecover)
                }else{
                    return deviceManager.settingContactInfo(deviceId: (deviceManager.currentDevice?.deviceId)!, contactInfo: (self.contactInfo?.value)!).map({ _ in
                        return ValidationResult.ok(message: "Set Success.")
                    }).asDriver(onErrorRecover: errorRecover)
                }
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


