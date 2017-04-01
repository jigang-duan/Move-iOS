//
//  MoveApiUserWorker.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/20.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class MoveApiUserWorker: UserWorkerProtocl {
    
    public enum LoginType: String{
        case none = ""
        case twitter = "twitter"
        case facebook = "facebook"
        case google = "google+"
    }
    
    func tplogin(platform: LoginType,openld: String,secret: String) -> Observable<Bool> {
        return MoveApi.Account.tplogin(info: MoveApi.TpLoginInfo(platform: platform.rawValue, openid: openld, secret: secret))
            .map(userInfoTransform)
            .catchError(errorHandle)
    }
    
    func login(email: String, password: String) -> Observable<Bool> {
        return MoveApi.Account.login(info: MoveApi.LoginInfo(username: email, password: password))
            .map(userInfoTransform)
            .catchError(errorHandle)
    }
    
    func isRegistered(account: String) -> Observable<Bool> {
        return MoveApi.Account.isRegistered(account: account)
            .map { $0.isRegistered! }
            .catchError(errorHandle)
    }
    
    func signUp(username: String, password: String, sid: String, vcode: String) -> Observable<Bool> {
        var info = MoveApi.RegisterInfo()
        info.username = username
        info.email = username
        info.password = password
        info.sid = sid
        info.vcode = vcode
        return MoveApi.Account.register(registerInfo: info)
            .map(userInfoTransform)
            .catchError(errorHandle)
    }
    
    func sendVcode(to: String) -> Observable<MoveApi.VerificationCodeSend> {
        return MoveApi.VerificationCode.send(to: to)
            .map { info in
                if info.sid == nil {
                     throw WorkerError.emptyField("vcode is empty!")
                }
               return info
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    func checkVcode(sid: String, vcode: String) -> Observable<Bool> {
        return MoveApi.VerificationCode.verify(sid: sid, vcode: vcode)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func updatePasssword(sid: String, vcode: String, email: String, password: String) -> Observable<Bool> {
        let info = MoveApi.UserFindInfo(sid: sid, vcode: vcode, email: email, password: password)
        return MoveApi.Account.findPassword(info: info)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    private func wrapProfile(_ profile: MoveApi.UserInfoMap) -> UserInfo.Profile {
        UserInfo.shared.profile = UserInfo.Profile(username: profile.username,
                                                   password: profile.password,
                                                   nickname: profile.nickname,
                                                   email: profile.email,
                                                   phone: profile.phone,
                                                   iconUrl: profile.profile,
                                                   gender: profile.gender,
                                                   height: profile.height,
                                                   weight: profile.weight,
                                                   unit_value: profile.unit_value,
                                                   unit_weight_value: profile.unit_weight_value,
                                                   orientation: profile.orientation,
                                                   birthday: profile.birthday,
                                                   mtime: profile.mtime)
        return UserInfo.shared.profile!
    }
    
    func fetchProfile() -> Observable<UserInfo.Profile> {
        if let profile = UserInfo.shared.profile {
            return Observable.just(profile)
        }
        guard let userId = UserInfo.shared.id else {
            return Observable.empty()
        }
        return MoveApi.Account.getUserInfo(uid: userId)
            .map(wrapProfile)
    }
    
    func setUserInfo(userInfo: UserInfo.Profile, newPassword: String) -> Observable<Bool> {
        let info = MoveApi.UserInfoSetting(phone: userInfo.phone,
                                           email: userInfo.email,
                                           profile: userInfo.iconUrl,
                                           nickname: userInfo.nickname,
                                           password: userInfo.password,
                                           new_password: newPassword == "" ? nil : newPassword,
                                           gender: userInfo.gender,
                                           height: userInfo.height,
                                           weight: userInfo.weight,
                                           unit_value: userInfo.unit_value,
                                           unit_weight_value: userInfo.unit_weight_value,
                                           orientation: userInfo.orientation,
                                           birthday: userInfo.birthday,
                                           mtime: userInfo.mtime)
        return MoveApi.Account.settingUserInfo(uid: UserInfo.shared.id!, info: info)
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
    func logout() -> Observable<Bool> {
        return MoveApi.Account.logout()
            .map(errorTransform)
            .catchError(errorHandle)
    }
    
}


fileprivate func userInfoTransform(userInfo: UserInfo) throws ->Bool {
    if userInfo.id == nil {
        throw WorkerError.emptyField("user id is empty!")
    }
    if !userInfo.accessToken.isValidAndNotExpired {
        throw WorkerError.expired("access token is expired!")
    }
    return true
}



