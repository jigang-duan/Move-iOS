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
    
    func initSyncKey() -> Observable<Bool> {
        return worker.initSyncKey()
    }
    
    func checkSyncKey(synckeyList: [MoveIM.ImSynckey]) -> Observable<Bool> {
        return worker.checkSyncKey(synckeyList: synckeyList)
    }
    
    func syncData() -> Observable<Bool> {
        return worker.syncData()
    }
    
}


protocol IMWorkerProtocl {
    
    func getGroups() -> Observable<[ImGroup]>
    
    func getGroupInfo(gid: String) -> Observable<ImGroup>
    
    func initSyncKey() -> Observable<Bool>
    
    func checkSyncKey(synckeyList: [MoveIM.ImSynckey]) -> Observable<Bool>
    
    func syncData() -> Observable<Bool>
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
    var type: Int?
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

class MessageDataBaseManager {
    
    static let shared = MessageDataBaseManager()
    
    var uid: String? = nil
    var messageValue = 0
    var contactValue = 0
    var groupValue = 0
    
    var selector = 0
    
    var groupList: [ImGroup]? = []
    var memberList: [ImContact]? = []
    
    struct Message {
        var msg_id: String?
        var type: Int?
        var from: String?
        var to: String?
        var gid: String?
        var content: String?
        var contentType: Int? = -1
        var contentStatus: Int? = -1
        var op: Int?
        var notice: Int?
        var status: Int? = -1
        var duration: TimeInterval? = 0.0
        var createDate: Date?
    }
    
    var messageList: [Message]? = []
    
}

extension MessageDataBaseManager {

    fileprivate func fetchSynkey() -> MessageDataBaseManager {
        let realm = try! Realm()
        if let mySynKey = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: UserInfo.shared.id) {
            MessageDataBaseManager.shared.uid = mySynKey.uid
            MessageDataBaseManager.shared.messageValue = mySynKey.message
            MessageDataBaseManager.shared.contactValue = mySynKey.contact
            MessageDataBaseManager.shared.groupValue = mySynKey.group
        }
        
        return MessageDataBaseManager.shared
    }
    
    fileprivate func saveSynckey() {
        let realm = try! Realm()
        if let mySynckey = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: self.uid) {
            try! realm.write {
                mySynckey.message = self.messageValue
                mySynckey.contact = self.contactValue
                mySynckey.group = self.groupValue

            }
        } else {
            let entity = SynckeyEntity()
            entity.uid = self.uid
            entity.message = self.messageValue
            entity.contact = self.contactValue
            entity.group = self.groupValue
            try! realm.write {
                realm.add(entity)
            }
        }
    }
    
    
    fileprivate func saveMessage() {
        
        guard let messages = self.messageList else {
            return
        }
        let realm = try! Realm()
        for item in messages {
            if let messageEntity = realm.object(ofType: MessageEntity.self, forPrimaryKey: item.msg_id) {
                try! realm.write {
         
                    messageEntity.from = item.from
                    messageEntity.to = item.to
                    messageEntity.groupId = item.gid
                    messageEntity.content = item.content
                    messageEntity.contentType = item.contentType!
                    messageEntity.readStatus = item.contentStatus!
                    messageEntity.duration = item.duration!
                    messageEntity.status = item.status!
                    messageEntity.createDate = item.createDate
                }
            } else {
                let entity = MessageEntity()
                entity.id = item.msg_id
                entity.from = item.from
                entity.to = item.to
                entity.groupId = item.gid
                entity.content = item.content
                entity.contentType = item.contentType!
                entity.readStatus = item.contentStatus!
                entity.duration = item.duration!
                entity.status = item.status!
                entity.createDate = item.createDate
                
                try! realm.write {
                    realm.add(entity)
                }
            }

        }
    }
    
    fileprivate func saveGroup() {
        
        guard let grouplist = self.groupList else {
            return
        }
        let realm = try! Realm()
        for item in grouplist {
            if let groupEntity = realm.object(ofType: GroupEntity.self, forPrimaryKey: item.gid) {
                groupEntity.name = item.topic
                groupEntity.headPortrait = item.profile
                groupEntity.owner = item.owner
                groupEntity.flag = item.flag ??  -1
                groupEntity.createDate = item.ctime
            }
            else {
                let entity = GroupEntity()
                entity.id = item.gid
                entity.name = item.topic
                entity.headPortrait = item.profile
                entity.owner = item.owner
                entity.flag = item.flag ??  -1
                entity.createDate = item.ctime
                try! realm.write {
                    realm.add(entity)
                }
            }
        }
    }
    
    fileprivate func saveMember() {
        
        guard let _memberlist = self.memberList else {
            return
        }
        let realm = try! Realm()
        for item in _memberlist {
            if let memberEntity = realm.object(ofType: MemberEntity.self, forPrimaryKey: item.uid) {
                
                memberEntity.type = item.type ?? -1
                memberEntity.username = item.username
                memberEntity.nickname = item.nickname
                memberEntity.headPortrait = item.profile
                memberEntity.identity = item.identity?.transformIdentity()
                memberEntity.sex = item.sex ?? 0
                memberEntity.phone = item.phone
                memberEntity.email = item.email
                memberEntity.flag = item.flag ??  -1
            }
            else {
                let entity = MemberEntity()
                entity.id = item.uid
                entity.type = item.type ?? -1
                entity.username = item.username
                entity.nickname = item.nickname
                entity.headPortrait = item.profile
                entity.identity = item.identity?.transformIdentity()
                entity.sex = item.sex ?? 0
                entity.phone = item.phone
                entity.email = item.email
                entity.flag = item.flag ??  -1
                try! realm.write {
                    realm.add(entity)
                }
            }
        }
    }
    
    func convertContactInfo(contactList:[MoveIM.ImContact]?) {
        guard let _memberList = contactList else {
            return
        }
        
        memberList?.removeAll()
        
        for item in _memberList {
            var member = ImContact()
            member.admin = item.admin
            member.email = item.email
            member.flag = item.flag
            member.identity = Relation(input: item.identity!)
            member.nickname = item.nickname
            member.phone = item.phone
            member.profile = item.profile
            member.sex = item.sex
            member.time = item.time
            member.type = item.type
            member.uid = item.uid
            member.username = item.username
            memberList?.append(member)
        }
    }
    
    func convertMessage(messagelist:[MoveIM.ImMessage]?) {
        guard let _messageList = messagelist else {
            messageList = []
            return
        }
        
        messageList?.removeAll()
        
        for item in _messageList {
            var message = MessageDataBaseManager.Message()
            message.content = item.content
            message.contentStatus = item.content_status
            message.contentType = item.content_type
            message.createDate = item.ctime
            message.duration = Double(item.duration!)
            message.from = item.from
            message.gid = item.gid
            message.msg_id = item.msg_id
            message.notice = item.notice
            message.op = item.op
            message.status = item.status
            message.to = item.to
            message.type = item.type
            self.messageList?.append(message)
        }
    }

}




extension ObservableType where E == MoveIM.ImUserSynckey {
    func saveSynckey() -> Observable<Bool> {
        return flatMap { element -> Observable<Bool> in
            if let synckey = element.synckey {
                MessageDataBaseManager.shared.messageValue = synckey[0].value ?? 0
                MessageDataBaseManager.shared.contactValue = synckey[1].value ?? 0
                MessageDataBaseManager.shared.groupValue = synckey[2].value ?? 0
            } else {
                MessageDataBaseManager.shared.messageValue = 0
                MessageDataBaseManager.shared.contactValue = 0
                MessageDataBaseManager.shared.groupValue = 0
            }
            
            if let user = element.user {
                MessageDataBaseManager.shared.uid = user.uid
            } else {
                MessageDataBaseManager.shared.uid = UserInfo.shared.id
            }
            MessageDataBaseManager.shared.saveSynckey()
            
            return Observable.just(true)
        }
    }
}

extension ObservableType where E == MoveIM.ImSyncData {
    func saveSynData() -> Observable<Bool> {
        return flatMap { element -> Observable<Bool> in
            if let synckey = element.synckey {
                
//                for i in 0..<synckey.count {
//                    switch i {
//                    case 1:
//                        MessageDataBaseManager.shared.messageValue = synckey[i].value ?? 0
//                    case 2:
//                        MessageDataBaseManager.shared.contactValue = synckey[i].value ?? 0
//                    case 3:
//                        MessageDataBaseManager.shared.contactValue = synckey[i].value ?? 0
//                    default:
//                        break
//                    }
//                }
                MessageDataBaseManager.shared.messageValue = synckey[0].value ?? 0
                MessageDataBaseManager.shared.contactValue = synckey[1].value ?? 0
                MessageDataBaseManager.shared.groupValue = synckey[2].value ?? 0
            } else {
                MessageDataBaseManager.shared.messageValue = 0
                MessageDataBaseManager.shared.contactValue = 0
                MessageDataBaseManager.shared.groupValue = 0
            }
            MessageDataBaseManager.shared.uid = UserInfo.shared.id
            
            
            MessageDataBaseManager.shared.convertMessage(messagelist: element.messages)
            MessageDataBaseManager.shared.convertContactInfo(contactList: element.contacts)
            
            MessageDataBaseManager.shared.saveMessage()
            MessageDataBaseManager.shared.saveMember()
            MessageDataBaseManager.shared.saveSynckey()
            
            return Observable.just(true)
        }
    }
}

extension ObservableType where E == MoveIM.ImSelector {
    func saveSelector() -> Observable<Bool> {
        return flatMap { info -> Observable<Bool> in
            if let _selcter = info.selector {
               MessageDataBaseManager.shared.selector = _selcter
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        }
    }
}

