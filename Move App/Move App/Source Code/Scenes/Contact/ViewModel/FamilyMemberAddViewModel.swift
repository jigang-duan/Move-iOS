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
    
    var fid: String?
    
    init(
        input:(
        photo: Variable<UIImage?>,
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
            .flatMapLatest({ _ in
                if let photo = input.photo.value {
                    return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().map({ fid -> ValidationResult in
                        self.fid = fid
                        return ValidationResult.ok(message: "Send Success.")
                    }).asDriver(onErrorRecover: errorRecover)
                    .distinctUntilChanged({ (v1, v2) -> Bool in
                        return v1.isValid == v2.isValid
                    })
                }else{
                    return Driver.just(ValidationResult.ok(message: "Send Success."))
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
