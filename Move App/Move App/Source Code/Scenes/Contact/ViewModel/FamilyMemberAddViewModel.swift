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

    
    let doneEnabled: Driver<Bool>
    var doneResult: Driver<ValidationResult>?
    
    
    init(
        input:(
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
        
        
        self.doneEnabled = Driver.combineLatest( nameInvalidte, phoneInvalidte) {name, phone in
                name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        doneResult = input.doneTaps
            .map({ _ in
                return ValidationResult.ok(message: "Send Success.")
            })
            .asDriver()
        
    }
    
}


