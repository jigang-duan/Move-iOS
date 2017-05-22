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
import Kingfisher


class KidInformationViewModel {
    
    let nameValid: Driver<ValidationResult>
    let phoneValid: Driver<ValidationResult>
    
    let sending: Driver<Bool>
    
    let nextEnabled: Driver<Bool>
    var nextResult: Driver<ValidationResult>?
    
    var isForSetting = false
    
    init(
        input: (
            addInfo: Variable<DeviceBindInfo>,
            photo: Variable<UIImage?>,
            name: Driver<String>,
            phonePrefix: Driver<String>,
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
        
        
        nameValid = input.name.map { name in
            return validation.validateNickName(name)
        }
        
        phoneValid = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        let activity = ActivityIndicator()
        sending = activity.asDriver()
        
        
        nextEnabled = Driver.combineLatest(nameValid, phoneValid, sending) { name, phone, send in
                name.isValid && phone.isValid && !send
            }
            .distinctUntilChanged()
        
        let com = Driver.combineLatest(input.name, input.phonePrefix, input.phone, input.addInfo.asDriver()){($0, $1, $2, $3)}
        
        self.nextResult = input.nextTaps.withLatestFrom(com)
            .flatMapLatest({ name, phonePrefix, phone, addInfo in
                
                var f = addInfo
                f.nickName = name
                f.number = "\(phonePrefix) \(phone)"
                
                if self.isForSetting == true {
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().takeLast(1).flatMapLatest({ pid -> Observable<ValidationResult> in
                            f.profile = pid
                            KingfisherManager.shared.cache.store(photo, forKey: FSManager.imageUrl(with: pid))
                            return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: f.number, nickname: f.nickName, profile: pid, gender: f.gender, height: f.height, weight: f.weight, heightUnit: f.heightUnit, weightUnit: f.weightUnit, birthday: f.birthday, gid: nil, online: nil))
                                .trackActivity(activity)
                                .map({_ in
                                    self.updateDeviceUser(addInfo: f)
                                    return  ValidationResult.ok(message: "Update Success")
                                })
                            }).asDriver(onErrorRecover: commonErrorRecover)
                    }else{
                        return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: f.number, nickname: f.nickName, profile: f.profile, gender: f.gender, height: f.height, weight: f.weight, heightUnit: f.heightUnit, weightUnit: f.weightUnit, birthday: f.birthday, gid: nil, online: nil))
                            .trackActivity(activity)
                            .map({_  in
                                self.updateDeviceUser(addInfo: f)
                                return  ValidationResult.ok(message: "Update Success")
                            }).asDriver(onErrorRecover: commonErrorRecover)
                    }
                  
                }else{
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo).map{$0.fid}.filterNil().takeLast(1).flatMapLatest({ pid -> Observable<ValidationResult> in
                            f.profile = pid
                            KingfisherManager.shared.cache.store(photo, forKey: FSManager.imageUrl(with: pid))
                            return deviceManager.addDevice(firstBindInfo: f)
                                .trackActivity(activity)
                                .map({_ in
                                    return  ValidationResult.ok(message: "Bind Success")
                                })
                            
                        }).asDriver(onErrorRecover: commonErrorRecover)
                    }else{
                        return deviceManager.addDevice(firstBindInfo: f)
                            .trackActivity(activity)
                            .map({_ in
                                return  ValidationResult.ok(message: "Bind Success")
                            })
                            .asDriver(onErrorRecover: commonErrorRecover)
                    }
                }
            })
        
    }
    
    
    func  updateDeviceUser(addInfo: DeviceBindInfo) {
        
        var user = DeviceManager.shared.currentDevice?.user
        user?.number = addInfo.number
        user?.nickname = addInfo.nickName
        user?.profile = addInfo.profile
        user?.gender = addInfo.gender
        user?.height = addInfo.height
        user?.weight = addInfo.weight
        user?.heightUnit = addInfo.heightUnit
        user?.weightUnit = addInfo.weightUnit
        user?.birthday = addInfo.birthday
        
        DeviceManager.shared.currentDevice?.user = user
    }
    
    
}

