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
import AudioToolbox


class MessageServer {
    
    var syncSubject = BehaviorSubject<Bool>(value: false)
    
    static let share = MessageServer()
    
    var progressDownload: Observable<NoticeEntity>?
    
    func syncDataInitalization(disposeBag: DisposeBag) {
        let realm = try! Realm()
        if let uid = Me.shared.user.id {
            
            let syncObject = realm.objects(SynckeyEntity.self).filter("uid == %@", uid)
            
            let syncData = Observable<Int>.timer(2.0, period: 30.0, scheduler: MainScheduler.instance)
                .flatMapFirst { _ in IMManager.shared.checkSyncKey().catchErrorJustReturn(false) }
                .filter { $0 }
                .flatMapLatest { _ in
                    IMManager.shared.syncData()
                        .catchErrorJustReturn( (synckey: nil,
                                                messages: nil,
                                                members: nil,
                                                groups: nil,
                                                notices: nil,
                                                chatops: nil) )
                }
                .shareReplay(1)
            
            let messageObservable = syncData.map { $0.messages }
                .filterNil()
                .flatMap { Observable.from($0) }
                .share()
            
            messageObservable
                .subscribe(onNext: { (message) in
                    guard let sync = syncObject.first else {
                        return
                    }
                    
                    if let gid = message.groupId, gid != "" {
                        if let group = sync.groups.filter({ gid == $0.id }).first {
                            let readStatus = (uid == message.from) ? MessageEntity.ReadStatus.finished: nil
                            group.update(realm: realm, message: message, readStatus: readStatus)
                        }
                    } else if uid == message.to {
                        sync.groups.forEach { group in
                            if group.members.map({ $0.id }).contains(where: { message.from == $0 }) {
                                group.update(realm: realm, message: message)
                            }
                        }
                    } else if uid == message.from {
                        sync.groups.forEach { group in
                            if group.members.map({ $0.id }).contains(where: { message.to == $0 }) {
                                group.update(realm: realm, message: message, readStatus: .finished)
                            }
                        }
                    }
                })
                .addDisposableTo(disposeBag)
            
            messageObservable
                .filter { $0.from != uid }
                .bindNext({ (_) in
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    AudioServicesPlaySystemSound(1007)
                })
                .addDisposableTo(disposeBag)
            
            let reNotice = syncData.map { $0.notices }
                .filterNil()
                .flatMap { Observable.from($0) }
                
            progressDownload = reNotice.filter { $0.type == NoticeType.progressDownload.rawValue }
            
            reNotice.filter { $0.type != NoticeType.progressDownload.rawValue }
                .subscribe(onNext: { (notice) in
                    guard let sync = syncObject.first else {
                        return
                    }
                    sync.groups.forEach { (group: GroupEntity) in
                        if group.members.map({$0.id}).contains(where: {notice.from == $0}) {
                            group.update(realm: realm, notice: notice)
                        }
                    }
                })
                .addDisposableTo(disposeBag)
            
            syncData.map { $0.synckey }
                .filterNil()
                .subscribe(onNext: { item in
                    guard let sync = syncObject.first else {
                        return
                    }
                    try? realm.write {
                        sync.contact = item.contact
                        sync.group = item.group
                        sync.message = item.message
                    }
                })
                .addDisposableTo(disposeBag)
            
            // 删除 消息
            syncData.map { $0.chatops }
                .filterNil()
                .map { $0.filter({$0.type == ChatOpEntity.OpType.deleteMessage.rawValue}) }
                .flatMap { Observable.from($0) }
                .map { $0.id }
                .filterNil()
                .map { realm.object(ofType: MessageEntity.self, forPrimaryKey: $0) }
                .filterNil()
                .subscribe(realm.rx.delete())
                .addDisposableTo(disposeBag)
            
            
            syncData.map{ $0.groups }
                .filterNil()
                .flatMap { Observable.from($0) }
                .map { $0.id }
                .filterNil()
                .flatMapLatest { IMManager.shared.getGroupInfo(gid: $0).catchError(catchImGroupEmptyError) }
                .map(transform)
                .subscribe(realm.rx.add(update: true))
                .addDisposableTo(disposeBag)
            
        }
    }
    
    func subscribe() -> Disposable {
        let realm = try! Realm()
        return RxStore.shared.deviceInfosState.asObservable()
            .map({ $0.flatMap({$0.deviceId}).sorted() })
            .distinctUntilChanged({ $0.0 == $0.1 })
            .withLatestFrom(RxStore.shared.userId.asObservable())
            .filterNil()
            .map({ realm.object(ofType: SynckeyEntity.self, forPrimaryKey: $0) })
            //.filter { $0 == nil }
            .flatMapLatest { _ -> Observable<SynckeyEntity> in
                IMManager.shared.initSyncKey()
                .map {
                    $0.uid = Me.shared.user.id
                    return $0
                }.catchErrorJustReturn(SynckeyEntity())
            }
            .filter { $0.uid != nil }
            .flatMapLatest { Observable.combineLatest(Observable.just($0), IMManager.shared.getGroups().catchError(catchImGroupsEmptyError)) { ($0, $1) } }
            .map { transform(synckey: $0, groups: $1) }
            .map { (synckey, groups) in
                synckey.groups.append(objectsIn: groups)
                return synckey
            }
            .subscribe(realm.rx.add(update: true))
    }
    
    

}

fileprivate func transform(synckey: SynckeyEntity, groups: [ImGroup]) -> (SynckeyEntity, [GroupEntity]) {
    return (synckey, groups.map(transform))
}

fileprivate func transform(groups: [ImGroup]) -> [GroupEntity] {
    return groups.map(transform)
}

fileprivate func transform(group: ImGroup) -> GroupEntity {
    let entity = GroupEntity()
    entity.id = group.gid
    entity.name = group.topic
    entity.headPortrait = group.profile
    entity.owner = group.owner
    entity.flag = group.flag ?? GroupEntity.Flag.unknown.rawValue
    entity.createDate = group.ctime
    group.members?.forEach {
        let member = MemberEntity()
        member.gmid = "\($0.uid ?? "")@\(group.gid ?? "")"
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
    if
        let gid = group.gid,
        let realm = try? Realm(),
        let oldgroup = realm.object(ofType: GroupEntity.self, forPrimaryKey: gid) {
        entity.messages.append(objectsIn: oldgroup.messages)
        entity.notices.append(objectsIn: oldgroup.notices)
    }
    return entity
}

fileprivate func catchImGroupEmptyError(error: Error) -> Observable<ImGroup> {
    return Observable<ImGroup>.empty()
}

fileprivate func catchImGroupsEmptyError(error: Error) -> Observable<[ImGroup]> {
    return Observable<[ImGroup]>.empty()
}
