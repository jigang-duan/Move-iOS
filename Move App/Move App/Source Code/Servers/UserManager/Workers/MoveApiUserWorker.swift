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
        UserInfo.shared.profile = UserInfo.Profile(
            username: profile.username,
            password: profile.password,
            nickname: profile.nickname,
            email: profile.email,
            phone: profile.phone,
            iconUrl: profile.profile)
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
    
    
}
