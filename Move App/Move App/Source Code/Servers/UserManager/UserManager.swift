//
//  UserManager.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class UserManager {
    
    static let share = UserManager()

    fileprivate var worker: UserWorkerProtocl = MokUserInfoWorker()
    private let userInfo = UserInfo.share
}

extension UserManager {
    
    func getProfile() -> Observable<UserInfo.Profile> {
        return worker.fetchProfile()
    }
}


/// User Worker Protocl
protocol UserWorkerProtocl {
    func fetchProfile() -> Observable<UserInfo.Profile>
}

class UserInfo {
    
    static let share = UserInfo()
    
    var accessToken: AccessToken
    var id: String?
    
    private init() {
        accessToken = AccessToken()
    }
    
    struct AccessToken {
        var token: String?
        var refreshToken: String?
        var expiryAt: Date?
    }
    
    struct Profile {
        var username: String?
        var password: String?
        
        var nickname: String?
        
        var email: String?
        var phone: String?
        
        var icon: String?
    }
}


class MokUserInfoWorker: UserWorkerProtocl {
    func fetchProfile() -> Observable<UserInfo.Profile> {
        return Observable.just(
            UserInfo.Profile(username: "Paul.wang@tcl.com",
                             password: "password",
                             nickname: "Paul.wang",
                             email: "",
                             phone: "",
                             icon: nil)
        )
    }
}


extension ObservableType where E == MoveApi.AccessToken {
    func cachingToken() -> Observable<UserInfo> {
        return flatMap { element -> Observable<UserInfo> in
            UserInfo.share.accessToken.token = element.accessToken
            UserInfo.share.accessToken.refreshToken = element.accessToken
            UserInfo.share.accessToken.expiryAt = element.expiredAt
            UserInfo.share.id = element.uid
            return Observable.just(UserInfo.share)
        }
    }
}
