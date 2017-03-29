//
//  MoveApiIMWorker.swift
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

class MoveApiIMWorker: IMWorkerProtocl {
    
    func initSyncKey() -> Observable<SynckeyEntity> {
        return MoveIM.ImApi.initSyncKey()
    }
    
    func checkSyncKey(syncData: SynckeyEntity?) -> Observable<Bool> {
        guard let sync = syncData else {
            return Observable.empty()
        }
        
        let list = [
            MoveIM.ImSynckey(key: 1, value: sync.message),
            MoveIM.ImSynckey(key: 2, value: sync.contact),
            MoveIM.ImSynckey(key: 3, value: sync.group)]
        return MoveIM.ImApi.checkSyncKey(synckey: MoveIM.ImCheckSynkey(synckey:
            list.map({"\($0.key!)_\($0.value!)"}).joined(separator: "|")
        ))
    }
    
    func syncData(syncData: SynckeyEntity?) -> Observable<EntityType> {
        guard
            let data = syncData,
            let _ = try? Realm().objects(GroupEntity.self).first else {
            return Observable.empty()
        }
        let imSynData = MoveIM.ImSynDatakey(synckey: [
                    MoveIM.ImSynckey(key: 1, value: data.message),
                    MoveIM.ImSynckey(key: 2, value: data.contact),
                    MoveIM.ImSynckey(key: 3, value: data.group)])
        return MoveIM.ImApi.syncData(synckey: imSynData).map { $0.mapEntity() }
    }
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp> {
        return MoveIM.ImApi.sendChatMessage(messageInfo: message)
    }
    
    
    //    获取群组列表
    func getGroups() -> Observable<[ImGroup]> {
        return MoveIM.ImApi.getGroups().map({ $0.groups?.map(self.convertGroup) ?? [] })
    }
    
    //    查看群组信息
    func getGroupInfo(gid: String) -> Observable<ImGroup> {
        return MoveIM.ImApi.getGroupInfo(gid: MoveIM.ImGid(gid: gid))
            .map({self.convertGroup($0)})
    }

    
    func convertGroup(_ group: MoveIM.ImGroup) -> ImGroup {
        let members = group.members?.map {
            return ImContact(uid: $0.uid,
                              type: $0.type,
                              username: $0.username,
                              nickname: $0.nickname,
                              profile: $0.profile,
                              identity: Relation(input: $0.identity ?? ""),
                              phone: $0.phone,
                              email: $0.email,
                              time: $0.time,
                              sex: $0.sex,
                              flag: $0.flag,
                              admin: $0.admin)
        } ?? []
        return ImGroup(gid: group.gid,
                       topic: group.topic,
                       profile: group.profile,
                       owner: group.owner,
                       flag: group.flag,
                       ctime: group.ctime,
                       members: members)
    }
    
}


