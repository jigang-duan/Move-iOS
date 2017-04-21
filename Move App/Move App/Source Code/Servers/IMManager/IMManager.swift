//
//  IMManager.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift
import RxRealm


class IMManager {
    
    static let shared = IMManager()
    
    fileprivate var worker: IMWorkerProtocl!
    
    var synckeyData: SynckeyEntity? {
        let realm = try! Realm()
        guard let synKeyValue = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: UserInfo.shared.id) else {
            return nil
        }
        return synKeyValue
    }
    
    init() {
        worker = MoveApiIMWorker()
    }
}

extension IMManager {
    
    func getGroups() -> Observable<[ImGroup]> {
        return worker.getGroups()
    }
    
    func getGroupInfo(gid: String) -> Observable<ImGroup> {
        return worker.getGroupInfo(gid: gid)
    }
    
    func initSyncKey() -> Observable<SynckeyEntity> {
        return worker.initSyncKey()
    }
    
    func checkSyncKey() -> Observable<Bool> {
        return worker.checkSyncKey(syncData: synckeyData)
    }
    
    func syncData() -> Observable<EntityType> {
        return worker.syncData(syncData: synckeyData)
    }
    
    
    func sendChatEmoji(_ emoji: ImEmoji) -> Observable<ImEmoji> {
        return sendChatMessage(message: MoveIM.ImMessage(meoji: emoji))
            .map { $0.msg_id }
            .filterNil()
            .map { emoji.clone(msgId: $0) }
    }
    
    func sendChatVoice(_ voice: ImVoice) -> Observable<ImVoice> {
        return sendChatMessage(message: MoveIM.ImMessage(voice: voice))
            .map { $0.msg_id }
            .filterNil()
            .map { voice.clone(msgId: $0) }
    }
    
    func delete(message id: String) -> Observable<String> {
        return worker.delete(message: id)
    }
    
    
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp> {
        return worker.sendChatMessage(message: message)
    }
    
    func delete(messages ids: [String]) -> Observable<[String]> {
        return worker.delete(messages: ids).map({ _ in ids })
    }
    
    func deleteMessages(uid: String) -> Observable<Bool> {
        return worker.deleteMessages(uid: uid)
    }
    
    func deleteMessages(gid: String) -> Observable<Bool> {
        return worker.deleteMessages(gid: gid)
    }
    
    func mark(notification id: String) -> Observable<String> {
        return worker.mark(notification: id)
    }
    
    func mark(message id: String) -> Observable<String> {
        return worker.mark(message: id)
    }
}


protocol IMWorkerProtocl {
    
    func getGroups() -> Observable<[ImGroup]>
    
    func getGroupInfo(gid: String) -> Observable<ImGroup>
    
    func initSyncKey() -> Observable<SynckeyEntity>
    
    func checkSyncKey(syncData: SynckeyEntity?) -> Observable<Bool>
    
    func syncData(syncData: SynckeyEntity?) -> Observable<EntityType>
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp>
    
    func delete(message id: String) -> Observable<String>
    
    func delete(messages ids: [String]) -> Observable<Bool>
    func deleteMessages(uid: String) -> Observable<Bool>
    func deleteMessages(gid: String) -> Observable<Bool>
    
    func mark(notification id: String) -> Observable<String>
    func mark(message id: String) -> Observable<String>
}


struct ImGroup {
    var gid: String?
    var topic:String?
    var profile: String?
    var owner: String?
    var flag: Int?
    var ctime: Date?
    var members: [ImContact]?
}

struct ImContact {
    var uid: String?
    var type: Int?//联系人类型0 - 非注册用户 1 - 注册用户 2 - 注册设备
    var username: String?
    var nickname: String?
    var profile: String?
    var identity: Relation?
    var phone: String?
    var email: String?
    var time: Date?
    var sex: Int?
    var flag: Int?
    var admin: Bool?
}



enum ImOpType: Int {
/*
    操作类型
    1 - 进入聊天
    2 - 退出聊天
    3 - 删除消息
    4 - 撤销发送
    5 - 标记语音/视频已读
    6 - 清空聊天记录
    7 - 阅读消息
 */
    case enterChat = 1
    case outOfChat = 2
    case deleteMessage = 3
    case undoMessage = 4
    case tagRead = 5
    case clearChat = 6
    case readMessage = 7
}

struct ImChatOp {
    var msg_id: String?
    var from: String?
    var to: String?
    var gid: String?
    var ctime: Date?
    
    var op: ImOpType?
}


struct ImEmoji {
    var msg_id: String?
    var from: String?
    var to: String?
    var gid: String?
    var ctime: Date
    
    var content: EmojiType?
    
    var failure: Bool?
}

struct ImVoice {
    var msg_id: String?
    var from: String?
    var to: String?
    var gid: String?
    var ctime: Date
    
    var fid: String?
    var readStatus: Int?
    var duration: Int?
    
    var locationURL: URL?
}


fileprivate extension MoveIM.ImMessage {
    init(op: ImChatOp) {
        self.init()
        self.type = 100
        self.from = op.from
        self.to = op.to
        self.gid = op.gid
        self.op = op.op?.rawValue
        self.content = op.msg_id
        self.ctime = op.ctime
    }
}


extension ImEmoji {
    
    fileprivate func clone(msgId: String) -> ImEmoji {
        return ImEmoji(msg_id: msgId, from: self.from, to: self.to, gid: self.gid, ctime: self.ctime, content: self.content, failure: self.failure)
    }
    
    func clone(failure: Bool) -> ImEmoji {
        return ImEmoji(msg_id: self.msg_id, from: self.from, to: self.to, gid: self.gid, ctime: self.ctime, content: self.content, failure: failure)
    }
    
    init(entity: MessageEntity) {
        self.init(msg_id: nil,
                  from: entity.from,
                  to: entity.to,
                  gid: entity.groupId,
                  ctime: entity.createDate ?? Date(),
                  content: EmojiType(rawValue: entity.content ?? ""),
                  failure: false)
        self.msg_id = (entity.readStatus == MessageEntity.ReadStatus.failedSend.rawValue) ? nil : entity.id
    }
}


extension ImVoice {
    
    fileprivate func clone(msgId: String) -> ImVoice {
        return ImVoice(msg_id: msgId,
                       from: self.from,
                       to: self.to,
                       gid: self.gid,
                       ctime: self.ctime,
                       fid: self.fid,
                       readStatus: self.readStatus,
                       duration: self.duration,
                       locationURL: self.locationURL)
    }
    
    func clone(fId: String) -> ImVoice {
        return ImVoice(msg_id: self.msg_id,
                       from: self.from,
                       to: self.to,
                       gid: self.gid,
                       ctime: self.ctime,
                       fid: fId,
                       readStatus: self.readStatus,
                       duration: self.duration,
                       locationURL: self.locationURL)
    }
    
    func clone(failure: Bool) -> ImVoice {
        var it = ImVoice(msg_id: self.msg_id,
                       from: self.from,
                       to: self.to,
                       gid: self.gid,
                       ctime: self.ctime,
                       fid: self.fid,
                       readStatus: self.readStatus,
                       duration: self.duration,
                       locationURL: self.locationURL)
        if failure {
            it.readStatus = MessageEntity.ReadStatus.failedSend.rawValue
        }
        return it
    }
    
    init(entity: MessageEntity) {
        self.init(msg_id: nil,
                  from: entity.from,
                  to: entity.to,
                  gid: entity.groupId,
                  ctime: entity.createDate ?? Date(),
                  fid: nil,
                  readStatus: entity.readStatus,
                  duration: Int(entity.duration),
                  locationURL: nil)
        self.msg_id = (entity.readStatus == MessageEntity.ReadStatus.failedSend.rawValue) ? nil : entity.id
        if let content = entity.content {
            if let url = URL(string: content), url.isFileURL {
                self.locationURL = url
            }
            self.fid = content
        }
    }
}

fileprivate extension MoveIM.ImMessage {
    init(meoji: ImEmoji) {
        self.init()
        self.type = 1
        self.msg_id = meoji.msg_id
        self.from = meoji.from
        self.to = meoji.to
        self.gid = meoji.gid
        self.content = meoji.content?.rawValue
        self.content_type = 1
        self.content_status = 0
        self.ctime = meoji.ctime
        
        self.locaId = Int(ctime!.timeIntervalSince1970).description
    }
}

fileprivate extension MoveIM.ImMessage {
    init(voice: ImVoice) {
        self.init()
        self.type = 1
        self.msg_id = voice.msg_id
        self.from = voice.from
        self.to = voice.to
        self.gid = voice.gid
        self.content = voice.fid
        self.content_type = 3
        self.content_status = voice.readStatus
        self.duration = voice.duration
        self.ctime = voice.ctime
        
        self.locaId = Int(ctime!.timeIntervalSince1970).description
    }
}


typealias EntityType = (
    synckey: SynckeyEntity?,
    messages:[MessageEntity]?,
    members: [MemberEntity]?,
    groups:  [GroupEntity]?,
    notices: [NoticeEntity]?,
    chatops: [ChatOpEntity]?
)

extension MoveIM.ImSyncData {

    func mapEntity() -> EntityType {
        return (
            synckey: SynckeyEntity(im: synckey),
            messages:messages?.flatMap { MessageEntity(im: $0) },
            members: contacts?.map { MemberEntity(im: $0) },
            groups:  groups?.map { GroupEntity(im: $0) },
            notices: messages?.flatMap { NoticeEntity(im: $0) },
            chatops: messages?.flatMap { ChatOpEntity(im: $0) }
        )
    }
}


extension SynckeyEntity {
    
    convenience init?(im synckeys: [MoveIM.ImSynckey]?) {
        guard let synckeys = synckeys else {
            return nil
        }
        let k1Index = synckeys.index { $0.key == 1 }
        let k2Index = synckeys.index { $0.key == 2 }
        let k3Index = synckeys.index { $0.key == 3 }
        if (k1Index == nil) && (k2Index == nil) && (k3Index == nil) {
            return nil
        }
        
        self.init()
        if let k1 = k1Index, let v1 = synckeys[k1].value {
            self.message = v1
        }
        if let k2 = k2Index, let v2 = synckeys[k2].value {
            self.contact = v2
        }
        if let k3 = k3Index, let v3 = synckeys[k3].value {
            self.group = v3
        }
    }
}

fileprivate extension ChatOpEntity {
    
    convenience init?(im message: MoveIM.ImMessage) {
        guard message.type == 1000 else {
            return nil
        }
        
        self.init()
        self.id = message.msg_id
        self.from = message.from
        self.to = message.to
        self.groupId = message.gid
        self.content = message.content
        self.type = message.op ?? ChatOpEntity.OpType.unknown.rawValue
        self.createDate = message.ctime
    }
}

fileprivate extension MessageEntity {
    
    convenience init?(im message: MoveIM.ImMessage) {
        guard message.type == 1 else {
            return nil
        }
        self.init()
        self.id = message.msg_id
        self.from = message.from
        self.to = message.to
        self.groupId = message.gid
        self.content = message.content
        self.contentType = message.content_type ?? MessageEntity.ContentType.unknown.rawValue
        self.readStatus = message.content_status ?? MessageEntity.ReadStatus.unknown.rawValue
        self.duration = TimeInterval(message.duration ?? 0)
        self.status = message.status ?? MessageEntity.Status.unknown.rawValue
        self.createDate = message.ctime
    }
}

extension MessageEntity {
    
    convenience init(meoji: ImEmoji) {
        let imMessage = MoveIM.ImMessage(meoji: meoji)
        self.init(im: imMessage)!
        if let failure = meoji.failure, failure {
            self.readStatus = MessageEntity.ReadStatus.failedSend.rawValue
        }
        if imMessage.msg_id == nil {
            self.id = imMessage.locaId
        }
    }
    
    convenience init(voice: ImVoice) {
        let imMessage = MoveIM.ImMessage(voice: voice)
        self.init(im: imMessage)!
        if imMessage.msg_id == nil {
            self.id = imMessage.locaId
        }
    }
    
    var hasContent: Bool {
        return self.content != nil
    }
    
    var isText: Bool {
        return self.contentType == MessageEntity.ContentType.text.rawValue
    }
    
    var isVoice: Bool {
        return self.contentType == MessageEntity.ContentType.voice.rawValue
    }
    
    var isSendFailed: Bool {
        return self.readStatus == MessageEntity.ReadStatus.failedSend.rawValue
    }
    
    var isTextOfFailed: Bool {
        return isText && isSendFailed && hasContent
    }
    
    var isVoiceOfFailed: Bool {
        return isVoice && isSendFailed && hasContent
    }
    
    var isGroup: Bool {
        return (groupId != nil) && (groupId != "")
    }
}

fileprivate extension GroupEntity {

    convenience init(im group: MoveIM.ImGroup) {
        self.init()
        self.id = group.gid
        self.name = group.topic
        self.headPortrait = group.profile
        self.owner = group.owner
        self.flag = group.flag ??  GroupEntity.Flag.unknown.rawValue
        self.createDate = group.ctime
    }
}

fileprivate extension MemberEntity {

    convenience init(im contact: MoveIM.ImContact) {
        self.init()
        self.id = contact.uid
        self.type = contact.type ?? MemberEntity.ContactType.unknown.rawValue
        self.username = contact.username
        self.nickname = contact.nickname
        self.headPortrait = contact.profile
        self.identity = contact.identity
        self.sex = contact.sex ?? MemberEntity.Sex.unknown.rawValue
        self.phone = contact.phone
        self.email = contact.email
        self.flag = contact.flag ?? MemberEntity.Flag.unknown.rawValue
    }
}

fileprivate extension NoticeEntity {
    
    convenience init?(im message: MoveIM.ImMessage) {
        guard message.type == 2 else {
            return nil
        }
        self.init()
        self.id = message.msg_id
        self.from = message.from
        self.to = message.to
        self.groupId = message.gid
        self.readStatus = message.content_status ?? NoticeEntity.ReadStatus.unknown.rawValue
        self.type = message.notice ?? NoticeType.unknown.rawValue
        self.createDate = message.ctime
        self.content = message.content
    }
}


