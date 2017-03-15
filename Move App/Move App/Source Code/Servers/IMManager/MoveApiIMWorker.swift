//
//  MoveApiIMWorker.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift


class MoveApiIMWorker: IMWorkerProtocl {
    
    func syncData() -> Observable<MoveIM.ImSyncData> {
        return MoveIM.ImApi.syncData()
    }
    
//    func convertImMessage(_ syncData: MoveIM.ImSyncData) -> ImSyncData {
//        var imsyncData = ImSyncData()
//        
//        if let messages = syncData.messages, messages.count > 0 {
//            imsyncData.messages = messages.map({ member in
//                var msg = ImMessage()
//                msg.content = member.content
//                msg.content_status = member.content_status
//                msg.content_type = member.content_type
//                msg.ctime = member.ctime
//                msg.from = member.from
//                msg.to = member.to
//                msg.gid = member.gid
//                msg.msg_id = member.msg_id
//                msg.notice = member.notice
//                msg.op = member.op
//                msg.status = member.status
//                msg.type = member.type
//                return msg
//            })
//            
//        }
//        else {
//            imsyncData.messages = []
//        }
//        
//        if let contacts = syncData.contacts, contacts.count > 0 {
//            imsyncData.contacts = contacts.map({ member in
//                var cts = ImContact()
//                cts.uid = member.uid
//                cts.type = member.type
//                cts.username = member.username
//                cts.nickname = member.nickname
//                cts.profile = member.profile
//                cts.identity = member.identity
//                cts.phone = member.phone
//                cts.email = member.email
//                cts.time = member.time
//                cts.sex = member.sex
//                cts.flag = member.flag
//                return cts
//            })
//        } else {
//            imsyncData.contacts = []
//        }
//        
//        if let groups = syncData.groups, groups.count > 0 {
//            imsyncData.groups = groups.map({ member in
//                var gp = ImGroup()
//                gp.gid = member.gid
//                gp.topic = member.topic
//                gp.profile = member.profile
//                gp.owner = member.owner
//                gp.flag = member.flag
//                
//                if let members = member.members, members.count > 0 {
//                    gp.members = members.map({ item in
//                        var m = ImContact()
//                        m.uid = item.uid
//                        m.nickname = item.nickname
//                        m.sex = item.sex
//                        m.username = item.username
//                        m.type = item.type
//                        m.flag = item.flag
//                        m.profile = item.profile
//                        m.identity = item.identity
//                        m.phone = item.phone
//                        m.email = item.email
//                        m.time = item.time
//                        return m
//                    })
//                }else{
//                    gp.members = []
//                }
//                return gp
//            })
//        } else {
//            imsyncData.groups = []
//        }
//        
//        
//        if let synckeys = syncData.synckey, synckeys.count > 0 {
//            imsyncData.synckey = synckeys.map({ synckey in
//                var m = ImSynckey()
//                m.key = synckey.key
//                m.value = synckey.value
//                return m
//            })
//        }else{
//            imsyncData.synckey = []
//        }
//        
//        return imsyncData
//    }

    
    func checkSyncKey(synckeyList: [ImSynckey]) -> Observable<MoveIM.ImSelector> {
        var synk = MoveIM.ImSynckeyList()
        let synckey = synckeyList.map({"\($0.key!)_\($0.value!)"}).joined(separator: "|")
        synk.synckey = synckey
        return MoveIM.ImApi.checkSyncKey(synckey: synk)
    }
    
//    func convertCheckSyncKey(_ selector: MoveIM.ImSelector) -> ImSelector {
//        var imSelector = ImSelector()
//        imSelector.selector = selector.selector
//        return imSelector
//    }

    
    func initSyncKey() -> Observable<MoveIM.ImUserSynckey> {
        return MoveIM.ImApi.initSyncKey()
    }
    
//    func convertUserSynckey(_ userSyncKey: MoveIM.ImUserSynckey) -> ImUserSynckey {
//        var usersyncKey = ImUserSynckey()
//        usersyncKey.user?.uid = userSyncKey.user?.uid
//        usersyncKey.user?.nickname = userSyncKey.user?.nickname
//        usersyncKey.user?.sex = userSyncKey.user?.sex
//        usersyncKey.user?.username = userSyncKey.user?.username
//        usersyncKey.user?.type = userSyncKey.user?.type
//        usersyncKey.user?.flag = userSyncKey.user?.flag
//        usersyncKey.user?.profile = userSyncKey.user?.profile
//        usersyncKey.user?.identity = userSyncKey.user?.identity
//        usersyncKey.user?.phone = userSyncKey.user?.phone
//        usersyncKey.user?.email = userSyncKey.user?.email
//        usersyncKey.user?.time = userSyncKey.user?.time
//        
//        if let synckeys = userSyncKey.synckey, synckeys.count > 0 {
//            usersyncKey.synckey = synckeys.map({ synckey in
//                var m = ImSynckey()
//                m.key = synckey.key
//                m.value = synckey.value
//                return m
//            })
//        }else{
//            usersyncKey.synckey = []
//        }
//        return usersyncKey
//    }
    
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


