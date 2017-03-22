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
    
    func checkSyncKey(synckeyList: [MoveIM.ImSynckey]?) -> Observable<Bool> {
        guard let list = synckeyList else {
            return Observable.empty()
        }

        return MoveIM.ImApi.checkSyncKey(synckey: MoveIM.ImCheckSynkey(synckey:
            list.map({"\($0.key!)_\($0.value!)"}).joined(separator: "|")
        ))
    }
    
    func syncData(syncData: MoveIM.ImSynDatakey?) -> Observable<Bool> {
        guard
            let data = syncData,
            let _ = try? Realm().objects(GroupEntity.self).first else {
            return Observable.empty()
        }
        return MoveIM.ImApi.syncData(synckey: data)
    }
    
    func sendChatMessage(message: MoveIM.ImMessage) -> Observable<MoveIM.ImMesageRsp> {
        return MoveIM.ImApi.sendChatMessage(messageInfo: message)
    }
    
    
//    获取群组列表
    func getGroups() -> Observable<[ImGroup]> {
        return MoveIM.ImApi.getGroups()
            .map({ info in
                var gs: [ImGroup]?
                if let gps = info.groups, gps.count > 0 {
                    gs = gps.map{self.convertGroup($0)}
                }
                return gs ?? []
            })
    }
    
    func convertGroup(_ group: MoveIM.ImGroup) -> ImGroup {
        var gp = ImGroup()
        gp.gid = group.gid
        gp.topic = group.topic
        gp.profile = group.profile
        gp.owner = group.owner
        gp.flag = group.flag
        if let members = group.members, members.count > 0 {
            gp.members = members.map({ member in
                var m = ImContact()
                m.uid = member.uid
                m.nickname = member.nickname
                m.sex = member.sex
                m.username = member.username
                m.type = member.type
                m.flag = member.flag
                m.profile = member.profile
                if let rl = member.identity {
                    m.identity = Relation(input: rl)
                }
                m.phone = member.phone
                m.email = member.email
                m.time = member.time
                m.admin = member.admin
                return m
            })
        }else{
            gp.members = []
        }
        return gp
    }
    
//    查看群组信息
    func getGroupInfo(gid: String) -> Observable<ImGroup> {
        let g = MoveIM.ImGid(gid: gid)
        return MoveIM.ImApi.getGroupInfo(gid: g)
            .map({self.convertGroup($0)})
    }
    
    
    
    
}


