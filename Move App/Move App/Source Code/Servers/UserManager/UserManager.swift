//
//  UserManager.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//


import Foundation
import RxSwift
import Realm
import RealmSwift
import RxRealm


class UserManager {
    
    static let shared = UserManager()

    fileprivate var worker: UserWorkerProtocl!
    private let userInfo = UserInfo.shared
    
    init() {
        worker = MoveApiUserWorker()
    }
}

extension UserManager {
    
    func getProfile() -> Observable<UserInfo.Profile> {
        return worker.fetchProfile()
    }
    
    func tplogin(platform: MoveApiUserWorker.LoginType,openld: String,secret: String) -> Observable<Bool> {
        return worker.tplogin(platform: MoveApiUserWorker.LoginType(rawValue: platform.rawValue)!, openld: openld, secret: secret)
    }
    
    func login(email: String, password: String) -> Observable<Bool> {
        return worker.login(email: email, password: password)
    }
    
    func isRegistered(account: String) -> Observable<Bool> {
        return worker.isRegistered(account: account)
    }
    
    func signUp(username: String, password: String, sid: String, vcode: String) -> Observable<Bool> {
        return worker.signUp(username: username, password: password, sid: sid, vcode: vcode)
    }
    
    func sendVcode(to: String, type: Int = 0) -> Observable<MoveApi.VerificationCodeSend>  {
        return worker.sendVcode(to: to, type: type)
    }
    
    func checkVcode(sid: String, vcode: String) -> Observable<Bool>{
        return worker.checkVcode(sid: sid, vcode: vcode)
    }
    
    func updatePasssword(sid: String, vcode: String, email: String, password: String) -> Observable<Bool> {
        return worker.updatePasssword(sid: sid, vcode: vcode, email: email, password: password)
    }
    
    func setUserInfo(userInfo: UserInfo.Profile, newPassword: String = "") -> Observable<Bool> {
        return worker.setUserInfo(userInfo: userInfo, newPassword: newPassword)
    }
    
    func logout() -> Observable<Bool> {
        return worker.logout()
    }
}


/// User Worker Protocl
protocol UserWorkerProtocl {
    
    func tplogin(platform: MoveApiUserWorker.LoginType,openld: String,secret: String) -> Observable<Bool>
    
    func login(email: String, password: String) -> Observable<Bool>
    
    func isRegistered(account: String) -> Observable<Bool>
    
    func fetchProfile() -> Observable<UserInfo.Profile>
    
    func signUp(username: String, password: String, sid: String, vcode: String) -> Observable<Bool>
    
    func sendVcode(to: String, type: Int) -> Observable<MoveApi.VerificationCodeSend>
    
    func checkVcode(sid: String, vcode: String) -> Observable<Bool>
    
    func updatePasssword(sid: String, vcode: String, email: String, password: String) -> Observable<Bool>
    
    func setUserInfo(userInfo: UserInfo.Profile, newPassword: String) -> Observable<Bool>
    
    func logout() -> Observable<Bool>
}

extension UserManager {
    
    func checkValid() -> Observable<Bool> {
        return UserInfo.shared.checkValid()
    }
    
    var isValidNativeToken: Observable<Bool> {
        return UserInfo.shared.isValidNativeToken
    }
    
    func cacheUserInfo() -> Observable<Bool> {
        return UserInfo.shared.cacheUserInfo()
    }
    
}


enum UnitType: Int {
    case metric = 0
    case british = 1
}

class UserInfo {
    
    static let shared = UserInfo()
    
    var id: String? {
        get {
            return RxStore.shared.userId.value
        }
        set(newValue) {
            RxStore.shared.userId.value = newValue
        }
    }
    
    var accessToken: AccessToken
    var profile: Profile?
    
    private init() {
        accessToken = AccessToken()
    }
    
    struct AccessToken {
        var token: String?
        var refreshToken: String?
        var expiryAt: Date?
        var refreshing: Bool = false
    }
    
    struct Profile {
        var username: String?
        var password: String?
        
        var nickname: String?
        
        var email: String?
        var phone: String?
        
        var iconUrl: String?
        var gender: Gender?
        var height: Int?
        var weight: Int?
        var heightUnit: UnitType?
        var weightUnit: UnitType?
        var orientation:Int?//手表携带位置
        var birthday: Date?
        var mtime: Date?//更新时间(更新数据时会自动修改,不用手动上传该参数)
    }
}

extension UserInfo {
    
    func invalidate() {
        self.accessToken.expiryAt = nil
        self.accessToken.token = nil
        self.accessToken.refreshToken = nil
        let realm = try! Realm()
        if let myAccount = realm.object(ofType: AccountEntity.self, forPrimaryKey: 0) {
            try! realm.write {
                realm.delete(myAccount)
            }
        }
        
    }
    
    func clean() {
        self.profile = nil
    }
    
    fileprivate func fetchUserInfo() -> UserInfo {
        let realm = try! Realm()
        if let myAccount = realm.object(ofType: AccountEntity.self, forPrimaryKey: 0) {
            UserInfo.shared.id = myAccount.uid
            UserInfo.shared.accessToken.token = myAccount.token
            UserInfo.shared.accessToken.refreshToken = myAccount.refreshToken
            UserInfo.shared.accessToken.expiryAt = myAccount.expired_at
        }
        
        return UserInfo.shared
    }
    
    fileprivate func saveAccessToken() {
        let realm = try! Realm()
        if let myAccount = realm.object(ofType: AccountEntity.self, forPrimaryKey: 0) {
            try! realm.write {
                myAccount.uid = self.id
                myAccount.token = self.accessToken.token
                myAccount.refreshToken = self.accessToken.refreshToken
                myAccount.expired_at = self.accessToken.expiryAt
            }
        } else {
            let entity = AccountEntity()
            entity.uid = self.id
            entity.token = self.accessToken.token
            entity.refreshToken = self.accessToken.refreshToken
            entity.expired_at = self.accessToken.expiryAt
            try! realm.write {
                realm.add(entity)
            }
        }
    }
    
    func checkValid() -> Observable<Bool> {
        let _ = fetchUserInfo()
        guard accessToken.isValidAndNotExpired else {
            return Observable.just(false)
        }
        
        guard let uid = id else {
            return Observable.just(false)
        }
        
        return MoveApi.Account.getUserInfo(uid: uid)
            .catchingUserProfile()
            .map { $0.username != nil }
            .catchErrorJustReturn(false)
    }
    
    var isValidNativeToken: Observable<Bool> {
        let _ = fetchUserInfo()
        guard accessToken.isValidAndNotExpired else {
            return Observable.just(false)
        }
        
        return Observable.just(id != nil)
    }
    
    func cacheUserInfo() -> Observable<Bool> {
        guard let uid = id else {
            return Observable.just(false)
        }
        return MoveApi.Account.getUserInfo(uid: uid)
            .catchingUserProfile()
            .map { $0.username != nil }
            .catchErrorJustReturn(false)
    }
    
    func cacheingUserInfo() -> Observable<UserInfo> {
        guard let uid = id else {
            return Observable.empty()
        }
        let userInfo = self
        return MoveApi.Account.getUserInfo(uid: uid)
            .catchingUserProfile()
            .map{_ in userInfo }
    }
    
}

extension UserInfo.AccessToken {
    
    var isValidAndNotExpired: Bool {
        guard let _ = self.token,
            let expiryAt = self.expiryAt else {
            return false
        }
        
        guard expiryAt.compare(Date()) == .orderedDescending else {
            return false
        }
        
        return true
    }
    
}


extension ObservableType where E == MoveApi.AccessToken {
    func catchingToken() -> Observable<UserInfo> {
        return flatMap { element -> Observable<UserInfo> in
            UserInfo.shared.accessToken.token = element.accessToken
            UserInfo.shared.accessToken.refreshToken = element.accessToken
            UserInfo.shared.accessToken.expiryAt = element.expiredAt
            UserInfo.shared.id = element.uid
            UserInfo.shared.saveAccessToken()
            return Observable.just(UserInfo.shared)
        }
    }
    
}


extension ObservableType where E == UserInfo {

    func pushToken() -> Observable<UserInfo> {
        return flatMapLatest { info in
            NotificationService.shared.fetchDeviceToken()
                .flatMapLatest { MoveApi.Account.settingPushToken(deviceId: $0) }
                .map {_ in info }
                .catchError {
                    if ($0 as NSError).isDeviceTokenError {
                        return Observable.just(info)
                    }
                    throw $0
                }
        }
    }
}


extension ObservableType where E == MoveApi.UserInfoMap {
    func catchingUserProfile() -> Observable<UserInfo.Profile> {
        return flatMap { $ -> Observable<UserInfo.Profile> in
            let profile = UserInfo.Profile(username: $.username,
                                           password: $.password,
                                           nickname: $.nickname,
                                           email: $.email,
                                           phone: $.phone,
                                           iconUrl: $.profile,
                                           gender: $.gender == "m" ? Gender.male:Gender.female,
                                           height: $.height,
                                           weight: $.weight,
                                           heightUnit: UnitType(rawValue: $.heightUnit ?? 0),
                                           weightUnit: UnitType(rawValue: $.weightUnit ?? 0),
                                           orientation: $.orientation,
                                           birthday: $.birthday,
                                           mtime: $.mtime)
            UserInfo.shared.profile = profile
            return Observable.just(profile)
        }
    }
}
