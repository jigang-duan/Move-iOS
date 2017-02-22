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
    
    func signUp(email: String, password: String) -> Observable<Bool> {
        var info = MoveApi.UserInfoMap()
        info.username = email
        info.password = password
        return MoveApi.Account.register(userInfo: info)
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
    
    func sendVcode(to: String) -> Observable<Bool> {
        return MoveApi.VerificationCode.send(to: to)
            .map { info in
                if info.sid == nil {
                    throw WorkerError.emptyField("vcode is empty!")
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
    
    // Mock
    func fetchProfile() -> Observable<UserInfo.Profile> {
        return Observable.just(UserInfo.Profile())
    }
    
}
