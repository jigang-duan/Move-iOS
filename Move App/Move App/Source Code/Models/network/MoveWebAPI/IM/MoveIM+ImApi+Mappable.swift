//
//  MoveApi+IM+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveIM {
    
    struct ImGid {
        var gid: String?
    }
    
    struct ImGroupList {
        var groups: [ImGroup]?
    }
    
    struct ImGroup {
        var gid: String?
        var topic:String?
        var profile: String?
        var owner: String?
        var flag: Int?
        var members: [ImContact]?
    }
    
    struct ImContact {
        var uid: String?
        var type: Int?//联系人类型0 - 非注册用户 1 - 注册用户 2 - 注册设备
        var username: String?
        var nickname: String?
        var profile: String?
        var identity: String?
        var phone: String?
        var email: String?
        var time: Date?
        var sex: Int?
        var flag: Int?//联系人标识位:标识位 0x00 - 已拉黑 0x01 - 好友 0x80 - 等待验证的用户 0x100 - 紧急联系人
        var admin: Bool?//true -- 管理员   false -- 非管理员
    }
}

extension MoveIM.ImGid: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        gid <- map["gid"]
    }
}


extension MoveIM.ImGroupList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        groups <- map["groups"]
    }
}

extension MoveIM.ImGroup: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        gid <- map["gid"]
        topic <- map["topic"]
        profile <- map["profile"]
        owner <- map["owner"]
        flag <- map["flag"]
        members <- map["members"]
    }
}

extension MoveIM.ImContact: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uid <- map["uid"]
        username <- map["username"]
        nickname <- map["nickname"]
        sex <- map["sex"]
        type <- map["type"]
        profile <- map["profile"]
        flag <- map["flag"]
        identity <- map["identity"]
        phone <- map["phone"]
        email <- map["email"]
        time <- map["time"]
        admin <- map["admin"]
    }
}
