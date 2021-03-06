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
    
    struct RegisterInfo {
        var sid: String?
        var vcode: String?
        var phone: String?
        var email: String?
        var profile: String?
        var nickname: String?
        var username: String?
        var password: String?
    }
    
    struct UserInfoMap {
        var uid: String?
        var phone: String?
        var email: String?
        var profile: String?
        var nickname: String?
        var username: String?
        var password: String?
        var gender: String?
        var height: Int?
        var weight: Int?
        var heightUnit: Int?
        var weightUnit: Int?
        var orientation:Int?//手表携带位置
        var birthday: Date?
        var mtime: Date?//更新时间(更新数据时会自动修改,不用手动上传该参数)
    }
    
    struct LoginInfo {
        var username: String?
        var password: String?
        var deviceName: String?
        var date: Date?
        var dateString: String?
    }
    
    struct TpLoginInfo {
        var platform: String?
        var openid: String?
        var secret: String?
        var deviceName: String?
        var date: Date?
        var dateString: String?
    }
    
    struct  UserInfoSetting {
        var phone: String?
        var email: String?
        var profile: String?
        var nickname: String?
        var password: String?
        var new_password: String?
        var gender: String?
        var height: Int?
        var weight: Int?
        var heightUnit: Int?
        var weightUnit: Int?
        var orientation:Int?
        var birthday: Date?
        var mtime: Date?
    }
    
    struct UserFindInfo {
        var sid: String?
        var vcode: String?
        var email: String?
        var password: String?
    }
    
    struct PushTokenInfo {
        var type: String?
        var deviceId: String?
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
        expiredAt <- (map["expired_at"], DateIntTransform())
    }
}

extension MoveApi.Registered: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        isRegistered <- map["registered"]
    }
}

extension MoveApi.RegisterInfo: Mappable{
    init?(map: Map) {
    }
    
    init(username: String, password: String, sid: String, vcode: String) {
        self.username = username
        self.password = password
        self.sid = sid
        self.vcode = vcode
    }
    
    mutating func mapping(map: Map) {
        sid <- map["sid"]
        vcode <- map["vcode"]
        phone <- map["phone"]
        email <- map["email"]
        profile <- map["profile"]
        nickname <- map["nickname"]
        username <- map["username"]
        password <- map["password"]
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
        gender <- map["gender"]
        height <- map["height"]
        weight <- map["weight"]
        heightUnit <- map["height_unit"]
        weightUnit <- map["weight_unit"]
        orientation <- map["orientation"]
        birthday <- (map["birthday"], DateIntTransform())
        mtime <- (map["mtime"], DateIntTransform())
    }
}

extension MoveApi.LoginInfo: Mappable{
    init?(map: Map) {
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        self.deviceName = UIDevice.current.name
        self.date = Date(timeIntervalSinceNow: 0)
        self.dateString = date?.stringDefaultDescription
    }
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        password <- map["password"]
        deviceName <- map["devicename"]
        date <- map["devicetime"]
        dateString <- map["devicetimes"]
    }
}

extension MoveApi.TpLoginInfo: Mappable{
    init?(map: Map) {
    }
    
    init(platform: String, openid: String, secret: String) {
        self.platform = platform
        self.openid = openid
        self.secret = secret
        self.deviceName = UIDevice.current.name
        self.date = Date(timeIntervalSinceNow: 0)
        self.dateString = date?.stringDefaultDescription
    }
    
    mutating func mapping(map: Map) {
        platform <- map["platform"]
        openid <- map["openid"]
        secret <- map["secret"]
        deviceName <- map["devicename"]
        date <- map["devicetime"]
        dateString <- map["devicetimes"]
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
        gender <- map["gender"]
        height <- map["height"]
        weight <- map["weight"]
        heightUnit <- map["height_unit"]
        weightUnit <- map["weight_unit"]
        orientation <- map["orientation"]
        birthday <- (map["birthday"], DateIntTransform())
        mtime <- (map["mtime"], DateIntTransform())
    }
}

extension MoveApi.UserFindInfo: Mappable{
    init?(map: Map) {
    }
    

    mutating func mapping(map: Map) {
        sid <- map["sid"]
        vcode <- map["vcode"]
        email <- map["email"]
        password <- map["password"]
    }
}

extension MoveApi.PushTokenInfo: Mappable{
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        deviceId <- map["device_id"]
    }
}
