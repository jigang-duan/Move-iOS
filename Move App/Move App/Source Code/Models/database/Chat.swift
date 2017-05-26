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


class GroupEntity: Object {
    
    /*
     标识位
     0x100 - 家庭联系人群组
     */
    enum Flag: Int {
        case unknown = -100
        case family = 0x100
    }
    
    dynamic var id: String? = nil
    dynamic var name: String? = nil
    dynamic var headPortrait: String? = nil
    dynamic var owner: String? = nil
    dynamic var flag = Flag.unknown.rawValue
    dynamic var createDate: Date?
    
    let members = List<MemberEntity>()
    let messages = List<MessageEntity>()
    let notices = List<NoticeEntity>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension GroupEntity {
    
    func markRead(realm: Realm, message id: String) {
        if let message = messages.filter({ $0.id == id }).first {
            try? realm.write {
                message.readStatus = MessageEntity.ReadStatus.read.rawValue
            }
        }
    }
    
    func update(realm: Realm, message: MessageEntity, readStatus: MessageEntity.ReadStatus?) {
        if let status = readStatus {
            message.readStatus = status.rawValue
        }
        self.update(realm: realm, message: message)
    }
    
    func update(realm: Realm, message: MessageEntity) {
        guard let messageId = message.id else {
            return
        }
        
        if let indexSame = self.messages.index(where: { $0.id == messageId }) {
            let same = self.messages[indexSame]
            if
                same.readStatus == MessageEntity.ReadStatus.failedSend.rawValue,
                message.readStatus == MessageEntity.ReadStatus.failedSend.rawValue {
                return
            }
            try? realm.write {
                realm.delete(same)
                self.messages.insert(message, at: indexSame)
            }
        } else if let indexOld = self.messages.index(where: { $0.createDate == message.createDate }) {
            let old = self.messages[indexOld]
            try? realm.write {
                realm.delete(old)
                self.messages.insert(message, at: indexOld)
            }
        } else {
            try? realm.write {
                self.messages.append(message)
            }
        }
        
    }
    
    func update(realm: Realm, messages: [MessageEntity]) {
        let olds: [MessageEntity] = self.messages.filter({ it in
            messages.contains(where: { $0.id == it.id })
        })
        try? realm.write {
            realm.delete(olds)
            self.messages.append(objectsIn: messages)
        }
    }
    
    func update(realm: Realm, notice: NoticeEntity) {
        let sameIdEntity = self.notices.filter({ $0.id == notice.id }).first
        try? realm.write {
            if let same = sameIdEntity {
                realm.delete(same)
            }
            self.notices.append(notice)
        }
    }
    
    func update(realm: Realm, notices: [NoticeEntity]) {
        let olds: [NoticeEntity] = self.notices.filter({ it in
            notices.contains(where: { $0.id == it.id })
        })
        try? realm.write {
            realm.delete(olds)
            self.notices.append(objectsIn: notices)
        }
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
        case unknown = -100
        case blackFriend = 0x0000
        case friend = 0x0001
        case toVerifyUser = 0x0080
        case emergency = 0x0100
    }
    
    enum Sex: Int {
        case unknown = 0
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
        case unknown = -100
    }
    
    dynamic var id: String? = nil
    dynamic var type = ContactType.unknown.rawValue
    dynamic var username: String? = nil
    dynamic var nickname: String? = nil
    dynamic var headPortrait: String? = nil
    dynamic var identity: String? = nil
    dynamic var sex = Sex.unknown.rawValue
    dynamic var phone: String? = nil
    dynamic var email: String? = nil
    dynamic var flag = Flag.unknown.rawValue
    
    let owners = LinkingObjects(fromType: GroupEntity.self, property: "members")
    
    dynamic var gmid: String? = nil
    
    override static func primaryKey() -> String? {
        return "gmid"
    }
    
}


extension MemberEntity {
    
    var relation: Relation? {
        guard let identity = self.identity else {
            return nil
        }
        return Relation(input: identity)
    }
}


class ChatOpEntity: Object {
    
    /*
     1 - 进入聊天
     2 - 退出聊天
     3 - 删除消息
     4 - 撤销发送
     5 - 标记语音/视频已读
     6 - 清空聊天记录
     7 - 阅读消息
     */
    enum OpType: Int {
        case unknown = -100
        case joinChat = 1
        case quitChat = 2
        case deleteMessage = 3
        case undoMessage = 4
        case flagRead = 5
        case clearMessage = 6
        case readMessage = 7
    }
    
    dynamic var id: String? = nil
    dynamic var from: String? = nil
    dynamic var to: String? = nil
    dynamic var groupId: String? = nil
    dynamic var content: String?
    dynamic var type = OpType.unknown.rawValue
    dynamic var createDate: Date? = nil
    
    //let owners = LinkingObjects(fromType: ChatOpEntity.self, property: "chatops")
    
    override static func primaryKey() -> String? {
        return "id"
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
        case unknown = -100
        case text = 1
        case image = 2
        case voice = 3
        case video = 4
    }
    /*
     0 - 未读
     1 - 已读
     101 - 发送了: - 发送成功了，但还没用通过服务器同步
     102 - 发送失败
     100 - 成功: - 通过服务器同步
     */
    enum ReadStatus: Int {
        case unknown = -100
        case unread = 0
        case read = 1
        case sent = 101
        case failedSend = 102
        case finished = 100
    }
    
    enum Status: Int {
        case unknown = -100
    }
    
    dynamic var id: String?
    
    dynamic var from: String?
    dynamic var to: String?
    dynamic var groupId: String?
    
    dynamic var content: String?
    dynamic var contentType = ContentType.unknown.rawValue
    
    dynamic var readStatus = ReadStatus.unknown.rawValue
    dynamic var status = Status.unknown.rawValue
    
    dynamic var duration: TimeInterval = 0.0
    
    dynamic var createDate: Date?
    
    let owners = LinkingObjects(fromType: GroupEntity.self, property: "messages")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


class SynckeyEntity: Object {
    
    dynamic var uid: String? = nil
        
    dynamic var message = 0
    dynamic var contact = 0
    dynamic var group = 0
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
    let groups = List<GroupEntity>()
}

extension SynckeyEntity {
    
    static func clearMessages() {
        if let realm = try? Realm() {
            let messages = realm.objects(MessageEntity.self)
            let notices = realm.objects(NoticeEntity.self)
            try? realm.write {
                realm.delete(messages)
                realm.delete(notices)
            }
        }
    }
    
}


extension MessageEntity {
    
    func clone(readStatus: ReadStatus) -> MessageEntity {
        self.readStatus = readStatus.rawValue
        return self
    }
}
