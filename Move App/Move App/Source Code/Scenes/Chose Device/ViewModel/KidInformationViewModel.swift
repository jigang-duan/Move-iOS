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
    
    var isForSetting: Bool?
    
    init(
        input: (
        photo: Variable<UIImage?>,
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
            return validation.validateNickName(name)
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
                var f = self.addInfo!
                
                if self.isForSetting == true {
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().flatMapLatest({ pid -> Observable<ValidationResult> in
                            f.profile = pid
                            return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: phone, nickname: name, profile: pid, gender: f.gender, height: f.height, weight: f.weight, birthday: f.birthday, gid: nil))
                                .map({_ -> ValidationResult in
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
                            }).asDriver(onErrorRecover: commonErrorRecover)
                    }else{
                        return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: phone, nickname: name, profile: f.profile, gender: f.gender, height: f.height, weight: f.weight, birthday: f.birthday, gid: nil))
                            .map({_ -> ValidationResult in
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
                            }).asDriver(onErrorRecover: commonErrorRecover)
                    }
                  
                }else{
                    f.nickName = name
                    f.phone = phone
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().flatMapLatest({ pid -> Observable<ValidationResult> in
                            f.profile = pid
                            return deviceManager.addDevice(firstBindInfo: f)
                                .map({_ in
                                    return  ValidationResult.ok(message: "Bind Success")
                                })
                            
                        }).asDriver(onErrorRecover: commonErrorRecover)
                    }else{
                        return deviceManager.addDevice(firstBindInfo: f)
                            .map({_ in
                                return  ValidationResult.ok(message: "Bind Success")
                            })
                            .asDriver(onErrorRecover: commonErrorRecover)
                    }
                }
            })
        
    }
    
}

