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
    
    let nameInvalidte: Driver<ValidationResult>
    let phoneInvalidte: Driver<ValidationResult>

    
    let saveEnabled: Driver<Bool>
    var saveResult: Driver<ValidationResult>?
    
    let doneEnabled: Driver<Bool>
    var doneResult: Driver<ValidationResult>?
    
    var photo: Variable<UIImage?>?
    
    var fid: String?
    
    init(
        input:(
        name: Driver<String>,
        number: Driver<String>,
        saveTaps: Driver<Void>,
        doneTaps: Driver<Void>
        ),
        dependency: (
        validation: DefaultValidation,
        wireframe: DefaultWireframe
        )
        ) {
        
        let validation = dependency.validation
        _ = dependency.wireframe
        
        
        
        nameInvalidte = input.name.map{name -> ValidationResult in
            if name.characters.count > 0{
                return ValidationResult.ok(message: "name avaliable")
            }
            return ValidationResult.empty
        }
        
        phoneInvalidte = input.number.map{number -> ValidationResult in
            return validation.validatePhone(number)
        }
        
        
        self.doneEnabled = Driver.combineLatest( nameInvalidte, phoneInvalidte) {name, phone in
                name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        self.saveEnabled = self.doneEnabled
        
        let com =  Driver.combineLatest( input.name, input.number){($0,$1)}
        
        
        saveResult = input.saveTaps.withLatestFrom(com)
            .flatMapLatest({self.operation(phone: $0.0, identity: $0.1)})
        
        doneResult = input.doneTaps.withLatestFrom(com)
            .flatMapLatest({self.operation(phone: $0.0, identity: $0.1)})
        
    }
    
    
    func  operation(phone: String, identity: String) -> Driver<ValidationResult> {
        let deviceManager = DeviceManager.shared
        
        if let photo = self.photo?.value.value {
            return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().takeLast(1).flatMap({ fid -> Observable<ValidationResult> in
                self.fid = fid
                
                return deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: fid, identity: Relation(input: identity)!).map({_ in
                    return ValidationResult.ok(message: "Send Success.")
                })
            })
                .asDriver(onErrorRecover: errorRecover)
        }else{
            return deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: nil, identity: Relation(input: identity)!).map({_ in
                return ValidationResult.ok(message: "Send Success.")
            })
                .asDriver(onErrorRecover: errorRecover)
        }
    }
    
}

fileprivate func errorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.identityIsExist == _error {
        return Driver.just(ValidationResult.failed(message: "Identity is Exists"))
    }
    
    
    return Driver.just(ValidationResult.failed(message: "Set faild"))
}
