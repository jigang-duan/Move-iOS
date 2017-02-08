//
//  MoveApi+Account+Mappable.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct AccessToken {
        var uid: String?
        var accessToken: String?
        var expiredAt: String?
    }
    
    struct Registered {
        var isRegistered: Bool?
    }
    
    struct RegisterInfo {
        var phone: String?
        var email: String?
        var profile: String?
        var nickname: String?
        var username: String?
        var password: String?
    }
    
    struct LoginInfo {
        var username: String?
        var password: String?
    }
    
    struct TpLoginInfo {
        var platform: String?
        var openif: String?
        var secret: String?
    }
}

extension MoveApi.Registered: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        isRegistered <- map["registered"]
    }
}
