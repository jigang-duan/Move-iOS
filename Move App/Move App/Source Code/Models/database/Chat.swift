//
//  Chat.swift
//  Move App
//
//  Created by yinxiao on 2017/3/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class GruopEntity: Object {
    
    /*
     标识位
     0x100 - 家庭联系人群组
     */
    enum Flag: Int {
        case unknow = -1
        case family = 0x100
    }
    
    dynamic var id: String? = nil
    dynamic var name: String? = nil
    dynamic var headPortrait: String? = nil
    dynamic var owner: String? = nil
    dynamic var flag = Flag.unknow.rawValue
    dynamic var createDate: Date?
    
    dynamic var uid: String? = nil
    
    let members = List<MemberEntity>()
    let messages = List<MessageEntity>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class MemberEntity: Object {
    
    /*
     联系人标识位:标识位
     0x00 - 已拉黑
     0x01 - 好友
     0x80 - 等待验证的用户
     0x100 - 紧急联系人
     */
    enum Flag: Int {
        case unknow = -1
        case blackFriend = 0x0000
        case friend = 0x0001
        case toVerifyUser = 0x0080
        case emergency = 0x0100
    }
    
    enum Sex: Int {
        case unknow = 0
        case male = 1
        case female = 2
    }
    
    /*
     联系人类型
     0 - 非注册用户
     1 - 注册用户
     2 - 注册设备
     */
    enum ContactType: Int {
        case unregisteredUser = 0
        case registeredUser = 1
        case registeredDevice = 2
        case unknow = -1
    }
    
    dynamic var id: String? = nil
    dynamic var type = ContactType.unknow.rawValue
    dynamic var username: String? = nil
    dynamic var nickname: String? = nil
    dynamic var headPortrait: String? = nil
    dynamic var identity: String? = nil
    dynamic var sex = Sex.unknow.rawValue
    dynamic var phone: String? = nil
    dynamic var email: String? = nil
    dynamic var flag = Flag.unknow.rawValue
    
    let owners = LinkingObjects(fromType: GruopEntity.self, property: "members")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var relation: Relation? {
        guard let identity = self.identity else {
            return nil
        }
        return Relation(input: identity)
    }
}

class MessageEntity: Object {
    
    /*
     1 - 普通文本消息
     2 - 图片消息，content为图片URL
     3 - 语音消息，content为语音URL
     4 - 视频消息，content为视频URL
     */
    enum ContentType: Int {
        case unknow = -1
        case text = 1
        case image = 2
        case voice = 3
        case video = 4
    }
    /*
     0 - 未读
     1 - 已读
     101 - 发送中
     102 - 发送失败
     100 - 发送成功
     */
    enum ReadStatus: Int {
        case unkonw = -1
        case unread = 0
        case read = 1
        case sending = 101
        case failedSend = 102
        case finishedSend = 100
    }
    
    dynamic var id: String?
    
    dynamic var from: String?
    dynamic var to: String?
    dynamic var gruopId: String?
    
    dynamic var content: String?
    dynamic var contentType = ContentType.unknow.rawValue
    
    dynamic var readStatus = ReadStatus.unkonw.rawValue
    dynamic var status = -1
    
    dynamic var duration: TimeInterval = 0.0
    
    dynamic var createDate: Date?
    
    dynamic var uid: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class SynckeyEntity: Object {
    
    dynamic var uid: String? = nil
    
    dynamic var message = 0
    dynamic var contact = 0
    dynamic var gruop = 0
    
    override static func primaryKey() -> String? {
        return "uid"
    }
}
