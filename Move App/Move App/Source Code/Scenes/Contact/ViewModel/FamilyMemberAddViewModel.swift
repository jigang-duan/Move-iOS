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
        nameText: Observable<String?>,
        name: Driver<String>,
        numberText: Observable<String?>,
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
        
        
        
        let textObserver = input.nameText.map{name -> ValidationResult in
            if let n = name {
                if n.characters.count > 0{
                    return ValidationResult.ok(message: "name avaliable")
                }
            }
            return ValidationResult.empty
        }
        
        let name = input.name.map{name -> ValidationResult in
            if name.characters.count > 0{
                return ValidationResult.ok(message: "name avaliable")
            }
            return ValidationResult.empty
        }
        nameInvalidte = Driver.of(textObserver.asDriver(onErrorJustReturn: .empty), name).merge()
        
        
        let numberTextObserver = input.numberText.map{number -> ValidationResult in
            if let n = number {
                if n.characters.count > 0{
                    return ValidationResult.ok(message: "number avaliable")
                }
            }
            return ValidationResult.empty
        }
        
        let number = input.number.map{number -> ValidationResult in
            if number.characters.count > 0{
                return ValidationResult.ok(message: "number avaliable")
            }
            return ValidationResult.empty
        }
        phoneInvalidte = Driver.of(numberTextObserver.asDriver(onErrorJustReturn: .empty), number).merge()
        
        
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


