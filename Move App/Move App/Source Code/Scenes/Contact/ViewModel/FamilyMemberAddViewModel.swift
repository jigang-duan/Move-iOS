//
//  FamilyMemberAddViewModel.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional


class FamilyMemberAddViewModel {
    
    
    let saveEnabled: Driver<Bool>
    var saveResult: Driver<ValidationResult>?

    let sending: Driver<Bool>
    
    init(
        input:(
        photo: Variable<UIImage?>,
        identity: Variable<Relation?>,
        prefix: Driver<String>,
        number: Driver<String>,
        saveTaps: Driver<Void>
        ),
        dependency: (
        validation: DefaultValidation,
        wireframe: DefaultWireframe
        )
        ) {
        
        let validate = dependency.validation
        _ = dependency.wireframe
        
        
        let activity = ActivityIndicator()
        sending = activity.asDriver()
        
        let numberInvalidate = input.number.map({number -> ValidationResult in
            return validate.validatePhone(number)
        })
        
        let identityInvalidte = input.identity.asDriver().map({$0 != nil})
        let numberNotEmpty = input.number.asDriver().map({$0 != ""})
        
        
        self.saveEnabled = Driver.combineLatest(identityInvalidte, numberNotEmpty, sending){$0 && $1 && !$2}
                            .distinctUntilChanged()
        
        
        let comNumber = Driver.combineLatest(numberInvalidate, input.prefix, input.number){($0, $1, $2)}
        
        saveResult = input.saveTaps.withLatestFrom(comNumber)
            .flatMapLatest({ res, prefix, number in
                if res.isValid == false {
                    return Driver.just(res)
                }
                
                var phone = ""
                if prefix == "" || prefix == "-" {
                    phone = number
                }else{
                    phone = "\(prefix)@\(number)"
                }
                
                let deviceManager = DeviceManager.shared
                
                if let photo = input.photo.value {
                    return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().takeLast(1)
                        .trackActivity(activity)
                        .flatMap({ fid -> Observable<ValidationResult> in
                             deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: fid, identity: input.identity.value!)
                                .trackActivity(activity)
                                .map({_ in
                                    return ValidationResult.ok(message: "Send Success.")
                                })
                        })
                        .asDriver(onErrorRecover: commonErrorRecover)
                }else{
                    return deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: nil, identity: input.identity.value!)
                        .trackActivity(activity)
                        .map({_ in
                            return ValidationResult.ok(message: "Send Success.")
                        })
                        .asDriver(onErrorRecover: commonErrorRecover)
                }
            })
        
    }
    
    
    
}
