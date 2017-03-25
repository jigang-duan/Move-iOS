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
    
    var progressDownload: Observable<NoticeEntity>?
    
    func syncDataInitalization(disposeBag: DisposeBag) {
        let realm = try! Realm()
        if
            let uid = Me.shared.user.id,
            let sync = realm.object(ofType: SynckeyEntity.self, forPrimaryKey: uid) {
            
            let syncData = Observable<Int>.timer(2.0, period: 30.0, scheduler: MainScheduler.instance).debug()
                .flatMapFirst {_ in
                    IMManager.shared.checkSyncKey()
                        .catchErrorJustReturn(false)
                }
                .filter { $0 }
                .flatMapLatest {_ in
                    IMManager.shared.syncData()
                        .catchErrorJustReturn(
                            (synckey: nil,messages: nil,members: nil,groups: nil,notices: nil,chatops: nil)
                    )
                }
                .shareReplay(1)
            
            syncData.map { $0.messages }
                .filterNil()
                .flatMap({ Observable.from($0) })
                .subscribe(onNext: {(message) in
                    if let gid = message.groupId, gid != "" {
                        if let group = sync.groups.filter({ gid == $0.id }).first {
                            group.update(realm: realm, message: message)
                        }
                    } else if uid == message.to {
                        sync.groups.forEach { group in
                            if group.members.map({ $0.id }).contains(where: { message.from == $0 }) {
                                group.update(realm: realm, message: message)
                            }
                        }
                    }
                })
                .addDisposableTo(disposeBag)

            
            let reNotice = syncData.map { $0.notices }
                .filterNil()
                .flatMap({ Observable.from($0) })
                
            progressDownload = reNotice.filter({ $0.type != NoticeType.progressDownload.rawValue })
            
            reNotice.filter({  $0.type != NoticeType.progressDownload.rawValue })
                .subscribe(onNext: { (notice) in
                    sync.groups.forEach({ (group: GroupEntity) in
                        if group.members.map({$0.id}).contains(where: {notice.from == $0}) {
                            group.update(realm: realm, notice: notice)
                        }
                    })
                })
//                .subscribe(onNext: { (notices) in
//                    sync.groups.forEach({ (group: GroupEntity) in
//                        let its = notices.filter({ it in
//                            group.members.map({$0.id}).contains(where: {it.from == $0})
//                        })
//                        group.update(realm: realm, notices: its)
//                    })
//                })
                .addDisposableTo(disposeBag)
            
            syncData.map({ $0.synckey })
                .filterNil()
                .subscribe(onNext: { item in
                    try! realm.write {
                        sync.contact = item.contact
                        sync.group = item.group
                        sync.message = item.message
                    }
                })
                .addDisposableTo(disposeBag)
        }
    }
    
    func subscribe() -> Disposable {
        let realm = try! Realm()
        return subject.asObservable()
            .filter({ $0 })
            .flatMapLatest{ _ -> Observable<SynckeyEntity> in
                IMManager.shared.initSyncKey()
                .map({
                    $0.uid = Me.shared.user.id
                    return $0
                }).catchErrorJustReturn(SynckeyEntity())
            }
            .filter({  $0.uid != nil })
            .flatMapLatest({
                Observable.combineLatest(Observable.just($0),
                                         IMManager.shared.getGroups().errorOnEmpty()) { ($0, $1)  }
            })
            .map({ self.transform(synckey: $0, groups: $1) })
            .map({ (synckey, groups) in
                synckey.groups.append(objectsIn: groups)
                return synckey
            })
            .subscribe(realm.rx.add(update: true))
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
        entity.flag = group.flag ?? GroupEntity.Flag.unknown.rawValue
        entity.createDate = group.ctime
        group.members?.forEach {
            let member = MemberEntity()
            member.id = $0.uid
            member.type = $0.type ?? MemberEntity.ContactType.unknown.rawValue
            member.username = $0.username
            member.nickname = $0.nickname
            member.headPortrait = $0.profile
            member.identity = $0.identity?.identity
            member.sex = $0.sex ?? MemberEntity.Sex.female.rawValue
            member.phone = $0.phone
            member.email = $0.email
            member.flag = $0.flag ??  MemberEntity.Flag.unknown.rawValue
            entity.members.append(member)
        }
        return entity
    }

}
