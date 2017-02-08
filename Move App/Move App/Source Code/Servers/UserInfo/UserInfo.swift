//
//  UserInfo.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift

class UserInfo {
    
    static var share = UserInfo()
    
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
