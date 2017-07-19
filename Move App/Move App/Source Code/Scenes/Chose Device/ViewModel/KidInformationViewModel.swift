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
        
        
        let nameValid = input.name.map { name in
            return validation.validateNickName(name)
        }
        
        let phoneValid = input.phone.map { phone in
            return validation.validatePhone(phone)
        }
        
        let activity = ActivityIndicator()
        sending = activity.asDriver()
        
        
        
        let nameNotEmpty = input.name.map { name in
            return name.characters.count > 0
        }
        
        let phoneNotEmpty = input.phone.map { phone in
            return phone.characters.count > 0
        }
        
        nextEnabled = Driver.combineLatest(nameNotEmpty, phoneNotEmpty, sending) { name, phone, send in
                name && phone && !send
            }
            .distinctUntilChanged()
        
        let com = Driver.combineLatest(nameValid, phoneValid, input.name, input.phonePrefix, input.phone, input.addInfo.asDriver()){($0, $1, $2, $3, $4, $5)}
        
        self.nextResult = input.nextTaps.withLatestFrom(com)
            .flatMapLatest({nameRes, phoneRes, name, phonePrefix, phone, addInfo in
                
                if nameRes.isValid == false {
                    return Driver.just(nameRes)
                }
                
                if phoneRes.isValid == false {
                    return Driver.just(phoneRes)
                }
                
                var f = addInfo
                f.nickName = name
                if phonePrefix == "" || phonePrefix == "-" {
                    f.number = phone
                }else{
                    f.number = "\(phonePrefix)@\(phone)"
                }
                
                if self.isForSetting == true {
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo)
                            .map{$0.fid}
                            .filterNil()
                            .takeLast(1)
                            .trackActivity(activity)
                            .flatMapLatest({ pid -> Observable<ValidationResult> in
                                f.profile = pid
                                KingfisherManager.shared.cache.store(photo, forKey: FSManager.imageUrl(with: pid))
                                return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: f.number, nickname: f.nickName, profile: pid, gender: f.gender, height: f.height, weight: f.weight, heightUnit: f.heightUnit, weightUnit: f.weightUnit, birthday: f.birthday, gid: nil, online: nil, owner: nil))
                                    .trackActivity(activity)
                                    .map({_ in
                                        self.updateDeviceUser(addInfo: f)
                                        return  ValidationResult.ok(message: "Update Success")
                                    })
                            })
                            .asDriver(onErrorRecover: commonErrorRecover)
                    }else{
                        return deviceManager.updateKidInfo(updateInfo: DeviceUser(uid: nil, number: f.number, nickname: f.nickName, profile: f.profile, gender: f.gender, height: f.height, weight: f.weight, heightUnit: f.heightUnit, weightUnit: f.weightUnit, birthday: f.birthday, gid: nil, online: nil, owner: nil))
                            .trackActivity(activity)
                            .map({_  in
                                self.updateDeviceUser(addInfo: f)
                                return  ValidationResult.ok(message: "Update Success")
                            }).asDriver(onErrorRecover: commonErrorRecover)
                    }
                  
                }else{
                    var userInfo = UserInfo.shared.profile
                    userInfo?.phone = f.phone
                    _ = UserManager.shared.setUserInfo(userInfo: userInfo!)
                        .map({ _ in
                        
                        })
                    
                    if let photo = input.photo.value {
                        return FSManager.shared.uploadPngImage(with: photo)
                            .map{$0.fid}
                            .filterNil()
                            .takeLast(1)
                            .trackActivity(activity)
                            .flatMapLatest({ pid -> Observable<ValidationResult> in
                                f.profile = pid
                                KingfisherManager.shared.cache.store(photo, forKey: FSManager.imageUrl(with: pid))
                                return deviceManager.addDevice(firstBindInfo: f)
                                    .trackActivity(activity)
                                    .map({_ in
                                        return  ValidationResult.ok(message: "Bind Success")
                                    })
                            })
                            .asDriver(onErrorRecover: commonErrorRecover)
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

