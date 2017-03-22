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
    
    var subject = BehaviorSubject<Bool>(value: false)
    
    static let share = MessageServer()
    
    func subscribe() -> Disposable {
        let realm = try! Realm()
        return subject.asObserver()
            .filter({ $0 })
            .flatMapLatest({ (_) -> Observable<SynckeyEntity> in
                let user = Me.shared.user
                if let entity = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: user.id) {
                    return Observable.just(entity)
                }
                return IMManager.shared.initSyncKey()
            })
            .flatMapLatest({
                Observable.combineLatest(Observable.just($0),
                                         IMManager.shared.getGroups().errorOnEmpty()) { ($0, $1)  }
            })
            .map(transform)
            .subscribe(onNext: { (synckey, groups) in
                try! realm.write {
                    synckey.groups.forEach({ (group) in
                        realm.delete(group.members)
                        realm.delete(group.messages)
                        realm.delete(group.notices)
                        realm.delete(group)
                    })
                    synckey.groups.append(objectsIn: groups)
                }
            })
    }
    
    
    private func syncData() -> Disposable {
        
        let realm = try! Realm()
        if
            let uid = Me.shared.user.id,
            let _ = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: uid) {
            
            return Driver<Int>.timer(2.0, period: 30.0)
                .flatMapFirst({_ in
                    IMManager.shared.checkSyncKey()
                        .asDriver(onErrorJustReturn: false)
                })
                .filter({ $0 })
                .flatMapLatest({ _ in
                    IMManager.shared.syncData()
                        .asDriver(onErrorJustReturn: false)
                })
                .drive(onNext: { _ in
                })
            
        }
        
        return Disposables.create()
    }
    
    private func transform(synckey: SynckeyEntity, groups: [ImGroup]) -> (SynckeyEntity, [GroupEntity]) {
        return (synckey, groups.map(transform))
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

}
