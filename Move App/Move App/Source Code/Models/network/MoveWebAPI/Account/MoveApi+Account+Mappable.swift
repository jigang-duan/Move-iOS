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
    
    struct AccessTokenReq {
        var uid: String?
        var name: String?
        var client: String?
    }
    
    struct AccessToken {
        var uid: String?
        var accessToken: String?
        var expiredAt: Date?
    }
    
    struct Registered {
        var isRegistered: Bool?
    }
    
    struct UserInfoMap {
        var uid: String?
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
        var openid: String?
        var secret: String?
    }
    
    struct  UserInfoSetting {
        var phone: String?
        var email: String?
        var profile: String?
        var nickname: String?
        var password: String?
        var new_password: String?
    }
    
    struct UserFindInfo {
        var username: String?
        var email: String?
        var phone: String?
        var password: String?
    }
}

extension MoveApi.AccessTokenReq: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        name <- map["name"]
        client <- map["client"]
    }
}

extension MoveApi.AccessToken: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        accessToken <- map["access_token"]
        expiredAt <- (map["expired_at"], DateTransform())
    }
}

extension MoveApi.Registered: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        isRegistered <- map["registered"]
    }
}

extension MoveApi.UserInfoMap: Mappable{
    init?(map: Map) {
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        phone <- map["phone"]
        email <- map["email"]
        profile <- map["profile"]
        nickname <- map["nickname"]
        username <- map["username"]
        password <- map["password"]
    }
}

extension MoveApi.LoginInfo: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        password <- map["password"]
    }
}

extension MoveApi.TpLoginInfo: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        platform <- map["platform"]
        openid <- map["openid"]
        secret <- map["secret"]
    }
}

extension MoveApi.UserInfoSetting: Mappable{
    init?(map: Map) {
    }
    
    init(password: String) {
        self.password = password
    }
    
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        email <- map["email"]
        profile <- map["profile"]
        nickname <- map["nickname"]
        new_password <- map["new_password"]
        password <- map["password"]
    }
}

extension MoveApi.UserFindInfo: Mappable{
    init?(map: Map) {
    }
    
    init(username: String) {
        self.username = username
    }
    
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        email <- map["email"]
        username <- map["username"]
        password <- map["password"]
    }
}
