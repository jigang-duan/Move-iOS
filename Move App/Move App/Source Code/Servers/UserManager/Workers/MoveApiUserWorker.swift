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
    
    func tplogin(platform: String,openld: String,secret: String) -> Observable<Bool> {
        var tpLoginInfo = MoveApi.TpLoginInfo()
        tpLoginInfo.platform = platform
        tpLoginInfo.openid = openld
        tpLoginInfo.secret = secret
        return MoveApi.Account.tplogin(info: tpLoginInfo)
            .map { info in
                if info.id == nil {
                    throw WorkerError.emptyField("user id is empty!")
                }
                if !info.accessToken.isValidAndNotExpired {
                    throw WorkerError.expired("access token is expired!")
                }
                return true
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    func login(email: String, password: String) -> Observable<Bool> {
        var loginInfo = MoveApi.LoginInfo()
        loginInfo.username = email
        loginInfo.password = password
        return MoveApi.Account.login(info: loginInfo)
            .map { info in
                if info.id == nil {
                    throw WorkerError.emptyField("user id is empty!")
                }
                if !info.accessToken.isValidAndNotExpired {
                    throw WorkerError.expired("access token is expired!")
                }
                return true
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
            }
    }
    
    func isRegistered(account: String) -> Observable<Bool> {
        return MoveApi.Account.isRegistered(account: account)
            .map { $0.isRegistered! }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    func signUp(username: String, password: String, sid: String, vcode: String) -> Observable<Bool> {
        var info = MoveApi.RegisterInfo()
        info.username = username
        info.email = username
        info.password = password
        info.sid = sid
        info.vcode = vcode
        return MoveApi.Account.register(registerInfo: info)
            .map { info in
                if info.id == nil {
                    throw WorkerError.emptyField("user id is empty!")
                }
                return true
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
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
            .map { info in
                if info.msg == "ok", info.id == 0 {
                    return true
                }
                throw WorkerError.webApi(id: info.id!, field: info.field, msg: info.msg)
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    func updatePasssword(sid: String, vcode: String, email: String, password: String) -> Observable<Bool> {
        let info = MoveApi.UserFindInfo(sid: sid, vcode: vcode, email: email, password: password)
        return MoveApi.Account.findPassword(info: info)
            .map { info in
                if info.msg == "ok", info.id == 0 {
                    return true
                }
                throw WorkerError.webApi(id: info.id!, field: info.field, msg: info.msg)
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    private func wrapProfile(_ profile: MoveApi.UserInfoMap) -> UserInfo.Profile {
        UserInfo.shared.profile = UserInfo.Profile(username: profile.username, password: profile.password, nickname: profile.nickname, email: profile.email, phone: profile.phone, iconUrl: profile.profile, gender: profile.gender, height: profile.height, weight: profile.weight, unit_value: profile.unit_value, unit_weight_value: profile.unit_weight_value, orientation: profile.orientation, birthday: profile.birthday, mtime: profile.mtime)
        return UserInfo.shared.profile!
    }
    
    // Mock
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
        var info = MoveApi.UserInfoSetting()
        info.nickname = userInfo.nickname
        info.password = userInfo.password
        info.new_password = newPassword == "" ? nil : newPassword
        info.phone = userInfo.phone
        info.email = userInfo.email
        info.gender = userInfo.gender
        info.height = userInfo.height
        info.weight = userInfo.weight
        info.unit_value = userInfo.unit_value
        info.unit_weight_value = userInfo.unit_weight_value
        info.orientation = userInfo.orientation
        info.birthday = userInfo.birthday
        info.mtime = userInfo.mtime
        info.profile = userInfo.iconUrl
        return MoveApi.Account.settingUserInfo(uid: UserInfo.shared.id!, info: info)
            .map { info in
                if info.msg == "ok", info.id == 0 {
                    return true
                }
                throw WorkerError.webApi(id: info.id!, field: info.field, msg: info.msg)
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }
    }
    
    
    
    func logout() -> Observable<Bool> {
        return MoveApi.Account.logout()
            .map { info in
                if info.msg == "ok", info.id == 0 {
                    return true
                }
                throw WorkerError.webApi(id: info.id!, field: info.field, msg: info.msg)
            }
            .catchError { error in
                if let _error = WorkerError.workerError(form: error) {
                    throw _error
                }
                throw error
        }

    }
    
    
    
}


















