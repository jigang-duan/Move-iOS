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
    
    var synckeyData: MoveIM.ImSynDatakey {
        var synData = MoveIM.ImSynDatakey()
        synData.synckey = []
        var synList = MoveIM.ImSynckey()
        let realm = try! Realm()
        if let synKeyValue = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: UserInfo.shared.id) {
            synList.key = 1
            synList.value = synKeyValue.message
            synData.synckey?.append(synList)
            synList.key = 2
            synList.value = synKeyValue.contact
            synData.synckey?.append(synList)
            synList.key = 3
            synList.value = synKeyValue.group
            synData.synckey?.append(synList)
        }
        else {
            synList.key = 1
            synList.value = 0
            synData.synckey?.append(synList)
            synList.key = 2
            synList.value = 0
            synData.synckey?.append(synList)
            synList.key = 3
            synList.value = 0
            synData.synckey?.append(synList)
        }
        return synData
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
    
    func initSyncKey() -> Observable<Bool> {
        return worker.initSyncKey()
    }
    
    func checkSyncKey() -> Observable<Bool> {
        return worker.checkSyncKey(synckeyList: synckeyData.synckey!)
    }
    
    func syncData() -> Observable<Bool> {
        return worker.syncData(syncData: synckeyData)
    }
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp> {
        return worker.sendChatMessage(message: message)
    }
    
}


protocol IMWorkerProtocl {
    
    func getGroups() -> Observable<[ImGroup]>
    
    func getGroupInfo(gid: String) -> Observable<ImGroup>
    
    func initSyncKey() -> Observable<Bool>
    
    func checkSyncKey(synckeyList: [MoveIM.ImSynckey]) -> Observable<Bool>
    
    func syncData(syncData: MoveIM.ImSynDatakey) -> Observable<Bool>
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp>
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

extension ObservableType where E == MoveIM.ImUserSynckey {
    func saveSynckey() -> Observable<Bool> {
        return flatMap { element -> Observable<Bool> in
            
            var userid: String?
            var messageValue: Int
            var contactValue: Int
            var groupValue: Int
            if let user = element.user {
                userid = user.uid
            } else {
                userid = UserInfo.shared.id
            }
            
            if let synckey = element.synckey {
                messageValue = synckey[0].value ?? 0
                contactValue = synckey[1].value ?? 0
                groupValue = synckey[2].value ?? 0
            } else {
                messageValue = 0
                contactValue = 0
                groupValue = 0
            }
            
            let realm = try! Realm()
            
            if let mySynckey = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: userid) {
                try! realm.write {
                    mySynckey.message = messageValue
                    mySynckey.contact = contactValue
                    mySynckey.group = groupValue
                    
                }
            } else {
                let entity = SynckeyEntity()
                entity.uid = userid
                entity.message = messageValue
                entity.contact = contactValue
                entity.group = groupValue
                try! realm.write {
                    realm.add(entity)
                }
            }
            return Observable.just(true)
        }
    }
}

extension ObservableType where E == MoveIM.ImSyncData {
    func saveSynData() -> Observable<Bool> {
        return flatMap { element -> Observable<Bool> in
            
            var messageValue: Int
            var contactValue: Int
            var groupValue: Int
            
            if let synckey = element.synckey {
                messageValue = synckey[0].value ?? 0
                contactValue = synckey[1].value ?? 0
                groupValue = synckey[2].value ?? 0
            } else {
                messageValue = 0
                contactValue = 0
                groupValue = 0
            }
            
            let realm = try! Realm()
            
            if let mySynckey = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: UserInfo.shared.id) {
                try! realm.write {
//                    mySynckey.uid = UserInfo.shared.id
                    mySynckey.message = messageValue
                    mySynckey.contact = contactValue
                    mySynckey.group = groupValue
                    
                }
            } else {
                let entity = SynckeyEntity()
                entity.uid = UserInfo.shared.id
                entity.message = messageValue
                entity.contact = contactValue
                entity.group = groupValue
                try! realm.write {
                    realm.add(entity)
                }
            }
            
            let _ = element.messages.map{$0.map{self.saveMessage(message: $0)}}
            let _ = element.contacts.map{$0.map{self.saveMember(member: $0)}}
            let _ = element.groups.map{$0.map{self.saveGroup(group: $0)}}
            return Observable.just(true)
        }
    }
    
    func saveMember(member: MoveIM.ImContact) {
        
        let realm = try! Realm()
        
        if let memberEntity = realm.object(ofType: MemberEntity.self, forPrimaryKey: member.uid) {
            try! realm.write {
                memberEntity.type = member.type ?? -1
                memberEntity.username = member.username
                memberEntity.nickname = member.nickname
                memberEntity.headPortrait = member.profile
                memberEntity.identity = member.identity
                memberEntity.sex = member.sex ?? 0
                memberEntity.phone = member.phone
                memberEntity.email = member.email
                memberEntity.flag = member.flag ??  -1
            }
        }
        else {
            let entity = MemberEntity()
            entity.id = member.uid
            entity.type = member.type ?? -1
            entity.username = member.username
            entity.nickname = member.nickname
            entity.headPortrait = member.profile
            entity.identity = member.identity
            entity.sex = member.sex ?? 0
            entity.phone = member.phone
            entity.email = member.email
            entity.flag = member.flag ??  -1
            try! realm.write {
                realm.add(entity)
            }
        }

    }
    
    func saveMessage(message: MoveIM.ImMessage) {
        let realm = try! Realm()
        
        if let messageEntity = realm.object(ofType: MessageEntity.self, forPrimaryKey: message.msg_id) {
            try! realm.write {
                
                messageEntity.from = message.from
                messageEntity.to = message.to
                messageEntity.groupId = message.gid
                messageEntity.content = message.content
                messageEntity.contentType = message.content_type!
                messageEntity.readStatus = message.content_status!
                messageEntity.duration = TimeInterval(message.duration!)
                messageEntity.status = message.status!
                messageEntity.createDate = message.ctime
            }
        } else {
            let entity = MessageEntity()
            entity.id = message.msg_id
            entity.from = message.from
            entity.to = message.to
            entity.groupId = message.gid
            entity.content = message.content
            entity.contentType = message.content_type!
            entity.readStatus = message.content_status!
            entity.duration = TimeInterval(message.duration!)
            entity.status = message.status!
            entity.createDate = message.ctime
            
            try! realm.write {
                realm.add(entity)
            }
        }
    }
    
    func saveGroup(group: MoveIM.ImGroup) {
        let realm = try! Realm()
        
        if let groupEntity = realm.object(ofType: GroupEntity.self, forPrimaryKey: group.gid) {
            try! realm.write {
                groupEntity.name = group.topic
                groupEntity.headPortrait = group.profile
                groupEntity.owner = group.owner
                groupEntity.flag = group.flag ??  -1
                groupEntity.createDate = group.ctime
                groupEntity.messages.removeAll()
                group.members?.forEach({ (member) in
                    let entity = MemberEntity()
                    entity.id = member.uid
                    entity.type = member.type ?? -1
                    entity.username = member.username
                    entity.nickname = member.nickname
                    entity.headPortrait = member.profile
                    entity.identity = member.identity
                    entity.sex = member.sex ?? 0
                    entity.phone = member.phone
                    entity.email = member.email
                    entity.flag = member.flag ??  -1
                    groupEntity.members.append(entity)
                })
            }
        }
        else {
            let entity = GroupEntity()
            entity.id = group.gid
            entity.name = group.topic
            entity.headPortrait = group.profile
            entity.owner = group.owner
            entity.flag = group.flag ??  -1
            entity.createDate = group.ctime
            group.members?.forEach({ (member) in
                let memberEntity = MemberEntity()
                memberEntity.id = member.uid
                memberEntity.type = member.type ?? -1
                memberEntity.username = member.username
                memberEntity.nickname = member.nickname
                memberEntity.headPortrait = member.profile
                memberEntity.identity = member.identity
                memberEntity.sex = member.sex ?? 0
                memberEntity.phone = member.phone
                memberEntity.email = member.email
                memberEntity.flag = member.flag ??  -1
                entity.members.append(memberEntity)
            })
            try! realm.write {
                realm.add(entity)
            }
        }
    }
    
}

extension ObservableType where E == MoveIM.ImSelector {
    func saveSelector() -> Observable<Bool> {
        return flatMap { info -> Observable<Bool> in
            if let _ = info.selector {
               //let selector = _selcter
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        }
    }
}

