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
    
    var firmwareUpdate: Observable<FirmwareUpdateType>?
    
    var lowBattery: Observable<Void>!
    var manuallyLocate: Observable<Void>!
    
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
                //.flatMap { Observable.from($0) }
                .share()
            
            messageObservable
                .do(onNext: { vibration(messages: $0, uid: uid) })
                .subscribe(onNext: { (messages) in
                    guard let sync = syncObject.first else {
                        return
                    }
                    classifiedSave(messages: messages, realm: realm, sync: sync, uid: uid)
                })
                .addDisposableTo(disposeBag)
            
//            messageObservable
//                //.filter { $0.from != uid }
//                .map{ $0.flatMap{$0.from}.filter{ $0 != uid }.first }
//                .filterNil()
//                .bindNext({ (_) in
//                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//                    AudioServicesPlaySystemSound(1007)
//                })
//                .addDisposableTo(disposeBag)
            
            let reNotice = syncData.map { $0.notices }
                .filterNil()
                .flatMap { Observable.from($0) }
            
            firmwareUpdate = reNotice
                .filter { $0.imType.isFirmwareUpdate }
                .map{ FirmwareUpdateType(notice: $0) }
                .filterNil()
                .scan(FirmwareUpdateType.empty, accumulator: accumulator)
            
            
            lowBattery = reNotice.filter{ $0.imType == .lowBatteryAlert }.map{_ in Void() }
            manuallyLocate = reNotice.filter{ $0.imType == .manuallyLocate }.map{ _ in Void() }
            
            let netNotice = reNotice.filter { $0.imType.needSave }.filter { ($0.to == nil) || ($0.to == uid) }
            
            let singleDevs = Observable.just(()).delay(5.0, scheduler: MainScheduler.instance)
                .flatMapLatest { RxStore.shared.deviceInfosObservable }
                .take(1)
                .flatMapLatest{ Observable.from($0) }
                .share()
            let deviceUpdateNotice = Observable.zip(singleDevs.map{ $0.deviceId }.filterNil(),
                                                    RxStore.shared.uidObservable,
                                                    singleDevs.map{ $0.user?.uid }.filterNil()) { ($0, $1, $2) }
                .flatMapLatest { UpdateServer.shared.deviceUpdateNoctice(device: $0, uid: $1, devUID: $2) }
            
            Observable.merge(netNotice, deviceUpdateNotice)
                .subscribe(onNext: { (notice) in
                    guard
                        let sync = syncObject.first,
                        let _ = notice.from else {
                        return
                    }
                    
                    if let gid = notice.groupId, gid != "" {
                        sync.groups.filter{ $0.id == gid }.first?.update(realm: realm, notice: notice)
                    } else {
                        sync.groups.forEach { (group: GroupEntity) in
                            if group.members.map({$0.id}).contains(where: {notice.from == $0}) {
                                group.update(realm: realm, notice: notice)
                            }
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

func vibration(messages: [MessageEntity], uid: String) {
    if let _ = messages.flatMap({$0.from}).filter({$0 != uid}).first {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(1007)
    }
}


fileprivate func classifiedSave(messages: [MessageEntity], realm: Realm, sync: SynckeyEntity, uid: String) {
//    DispatchQueue(label: "realm").async {
//        messages.forEach { it in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
//                save(message: it, realm: realm, sync: sync, uid: uid)
//            })
//        }
//    }
    let my = messages.filter({ $0.from == uid })
    save(messages: my, realm: realm, sync: sync, uid: uid)
    
    let others = messages.filter({ $0.from != uid })
    let gOthers = others.filter({ ($0.groupId != nil) && ($0.groupId != "") })
    let cgOthers = gOthers.reduce([:]) { (map, message) -> [String: [MessageEntity]] in
        var result = map
        if let gid = message.groupId {
            if result[gid] == nil {
                result[gid] = [MessageEntity]()
            }
            result[gid]?.append(message)
        }
        return result
    }
    cgOthers.forEach { (gid: String, values: [MessageEntity]) in
        if let group = sync.groups.filter({ gid == $0.id }).first {
            group.update(realm: realm, messages: values)
        }
    }
    let sOthers = others.filter({ ($0.groupId == nil) || ($0.groupId == "") })
    let fsOthers = sOthers.reduce([:]) { (map, message) -> [String: [MessageEntity]] in
        var result = map
        if let form = message.from {
            if result[form] == nil {
                result[form] = [MessageEntity]()
            }
            result[form]?.append(message)
        }
        return result
    }
    fsOthers.forEach { (from: String, values: [MessageEntity]) in
        sync.groups.forEach { group in
            if group.members.map({ $0.id }).contains(where: { from == $0 }) {
                group.update(realm: realm, messages: values)
            }
        }
    }
}

fileprivate func save(messages: [MessageEntity], realm: Realm, sync: SynckeyEntity, uid: String) {
    messages.forEach { save(message: $0, realm: realm, sync: sync, uid: uid) }
}

fileprivate func save(message: MessageEntity, realm: Realm, sync: SynckeyEntity, uid: String) {
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
}


fileprivate func accumulator(a: FirmwareUpdateType, item: FirmwareUpdateType) -> FirmwareUpdateType {
    switch (a, item) {
    case (.progressDownload(let i1), .progressDownload(let i2)):
        return i1 > i2 ? a : item
    default: return item
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
