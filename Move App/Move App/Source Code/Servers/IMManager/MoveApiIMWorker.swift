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


