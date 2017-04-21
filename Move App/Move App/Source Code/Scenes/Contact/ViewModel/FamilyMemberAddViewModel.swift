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
    
    var photo: Variable<UIImage?>?
    
    var exsitIdentities: [Relation] = []
    
    init(
        input:(
        name: Driver<String>,
        number: Driver<String>,
        saveTaps: Driver<Void>
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
        
        
        self.saveEnabled = Driver.combineLatest( nameInvalidte, phoneInvalidte) {name, phone in
                name.isValid && phone.isValid
            }
            .distinctUntilChanged()
        
        
        let com =  Driver.combineLatest( input.name, input.number){($0,$1)}
        
        
        saveResult = input.saveTaps.withLatestFrom(com)
            .flatMapLatest({self.operation(phone: $0.1, identity: $0.0)})
        
    }
    
    
    func  operation(phone: String, identity: String) -> Driver<ValidationResult> {
        let deviceManager = DeviceManager.shared
        
        if let photo = self.photo?.value.value {
            return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().takeLast(1).flatMap({ fid -> Observable<ValidationResult> in
                let relation = self.createIdentity(identity)
                return deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: fid, identity: relation).map({_ in
                    return ValidationResult.ok(message: "Send Success.")
                })
            })
                .asDriver(onErrorRecover: commonErrorRecover)
        }else{
            let relation = self.createIdentity(identity)
            return deviceManager.addNoRegisterMember(deviceId: (deviceManager.currentDevice?.deviceId)!, phone: phone, profile: nil, identity: relation).map({_ in
                return ValidationResult.ok(message: "Send Success.")
            })
                .asDriver(onErrorRecover: commonErrorRecover)
        }
    }
    
    
 
    func createIdentity(_ identity: String) -> Relation {
        var relation = Relation(input: identity)!
        
        for iden in exsitIdentities {
            if relation.description == iden.description {
                relation = createIdentity("\(identity)-1")
                break
            }
        }
        
        return relation
    }
    
    
}
