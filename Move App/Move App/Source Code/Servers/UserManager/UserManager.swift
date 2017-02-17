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
    
    static let shared = UserManager()

    fileprivate var worker: UserWorkerProtocl = MokUserInfoWorker()
    private let userInfo = UserInfo.shared
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
    
    static let shared = UserInfo()
    
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

extension UserInfo {
    
    func invalidate() {
        self.accessToken.expiryAt = nil
        self.accessToken.token = nil
        self.accessToken.refreshToken = nil
    }
}

extension UserInfo.AccessToken {
    
    var isValidAndNotExpired: Bool {
        guard let _ = self.token,
            let expiryAt = self.expiryAt else {
            return false
        }
        
        guard expiryAt.compare(Date()) == .orderedAscending else {
            return false
        }
        
        return true
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
    func catchingToken() -> Observable<UserInfo> {
        return flatMap { element -> Observable<UserInfo> in
            UserInfo.shared.accessToken.token = element.accessToken
            UserInfo.shared.accessToken.refreshToken = element.accessToken
            UserInfo.shared.accessToken.expiryAt = element.expiredAt
            UserInfo.shared.id = element.uid
            return Observable.just(UserInfo.shared)
        }
    }
}
