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
    
    let identityInvalidte: Driver<ValidationResult>
    let nameInvalidte: Driver<ValidationResult>
    let phoneInvalidte: Driver<ValidationResult>

    
    let doneEnabled: Driver<Bool>
    var doneResult: Driver<ValidationResult>?
    
    
    init(
        input:(
        identity: Driver<Int>,
        name: Driver<String>,
        number: Driver<String>,
        doneTaps: Driver<Void>
        ),
        dependency: (
        validation: DefaultValidation,
        wireframe: DefaultWireframe
        )
        ) {
        
        _ = dependency.validation
        _ = dependency.wireframe
        
        identityInvalidte = input.identity.map{ identity in
            if identity > 0{
                return ValidationResult.ok(message: "identity avaliable")
            }
            return ValidationResult.empty
        }
        
        nameInvalidte = input.name.map{name in
            if name.characters.count > 0{
                return ValidationResult.ok(message: "name avaliable")
            }
            return ValidationResult.empty
        }
        
        phoneInvalidte = input.number.map{number in
            if number.characters.count > 0{
                return ValidationResult.ok(message: "number avaliable")
            }
            return ValidationResult.empty
        }
        
        
        self.doneEnabled = Driver.combineLatest( identityInvalidte, nameInvalidte, phoneInvalidte) { identity, name, phone in
                identity.isValid && name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        doneResult = input.doneTaps
            .map({ _ in
                return ValidationResult.ok(message: "Send Success.")
            })
            .asDriver()
        
    }
    
}

fileprivate func protectAccountErrorRecover(_ error: Error) -> Driver<ValidationResult> {
    guard let _error = error as?  WorkerError else {
        return Driver.just(ValidationResult.empty)
    }
    
    if WorkerError.vcodeIsIncorrect == _error {
        return Driver.just(ValidationResult.failed(message: "Vcode is Incorrect"))
    }
    
    
    return Driver.just(ValidationResult.failed(message: "Send faild"))
}

