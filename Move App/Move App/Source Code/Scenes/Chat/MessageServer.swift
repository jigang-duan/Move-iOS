//
//  MessageServer.swift
//  Move App
//
//  Created by yinxiao on 2017/3/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm


class MessageServer {
    
    var subject = PublishSubject<Bool>()
    
    static let share = MessageServer()
    
    private var disposeBag: Disposable?
    
    func subscribe() {
        let realm = try! Realm()
    
        disposeBag = subject.asObserver().debug()
            .filter({ $0 })
            .flatMapLatest({ _ in
                IMManager.shared.getGroups()
                    .errorOnEmpty()
            })
            .map(transform).debug()
            .subscribe(realm.rx.add())
    }
    
    func unsubscribe() {
        disposeBag?.dispose()
    }
    
    private func transform(groups: [ImGroup]) -> [GroupEntity] {
        return groups.map(transform)
    }
    
    private func transform(group: ImGroup) -> GroupEntity {
        let entity = GroupEntity()
        entity.id = group.gid
        entity.name = group.topic
        entity.headPortrait = group.profile
        entity.owner = group.owner
        entity.flag = group.flag ?? GroupEntity.Flag.unknow.rawValue
        entity.createDate = group.ctime
        group.members?.forEach {
            let member = MemberEntity()
            member.id = $0.uid
            member.type = $0.type ?? MemberEntity.ContactType.unknow.rawValue
            member.username = $0.username
            member.nickname = $0.nickname
            member.headPortrait = $0.profile
            member.identity = $0.identity?.identity
            member.sex = $0.sex ?? MemberEntity.Sex.female.rawValue
            member.phone = $0.phone
            member.email = $0.email
            member.flag = $0.flag ??  MemberEntity.Flag.unknow.rawValue
            entity.members.append(member)
        }
        return entity
    }

    
    func getGroupInfo() {
        let realm = try! Realm()
        IMManager.shared.getGroups().map({ list in
            list.map({ group in
                
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
                            entity.identity = member.identity?.transformIdentity()
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
                        memberEntity.identity = member.identity?.transformIdentity()
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
                
            })
        }).bindNext{print($0)}
    }
}
