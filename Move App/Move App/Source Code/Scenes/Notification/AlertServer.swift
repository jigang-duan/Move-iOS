//
//  AlertServer.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/18.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealm


class AlertServer {
    
    static let share = AlertServer()
    
    let navigateLocationSubject = PublishSubject<KidSate.LocationInfo>()
    
    func subscribe(disposeBag: DisposeBag) {
        let realm = try! Realm()
        let objects = realm.objects(NoticeEntity.self)
        let notices = Observable.collection(from: objects)
            .share()
            
        let alertResult = notices
            .map { $0.filter({$0.readStatus == NoticeEntity.ReadStatus.unread.rawValue}).first }
            .filterNil()
            .flatMapLatest { (notice) -> Observable<AlertResult> in
                let kids = notice.owners.first?.members.filter({ $0.id == notice.from }).first
                guard let noticeType = NoticeType(rawValue: notice.type) else {
                    return Observable.empty()
                }
                let confirm = noticeType.style.hasConfirm ? AlertResult.confirm(parcel: notice) : nil
                return AlertWireframe.shared.prompt(notice.content ?? "",
                                                    title: noticeType.title,
                                                    iconURL: kids?.headPortrait?.fsImageUrl,
                                                    cancel: .ok(parcel: notice),
                                                    confirm: confirm, confirmTitle: noticeType.style.description)
            }
            .shareReplay(1)
        
        alertResult
            .map(transform)
            .filterNil()
            .flatMapLatest { notice -> Observable<NoticeEntity> in
                guard let noticeId = notice.id else {
                    return Observable.empty()
                }
                return IMManager.shared.mark(notification: noticeId).map {_ in notice }.catchErrorJustReturn(notice)
            }
            .bindNext { $0.makeRead(realm: realm) }
            .addDisposableTo(disposeBag)
        
        let confirmNotice = alertResult
            .filter { $0.isConfirm }
            .map(transform)
            .filterNil()
            .share()
        
        let okNotice = alertResult
            .filter { $0.isOK }
            .map(transform)
            .filterNil()
            .share()

        let navigate = confirmNotice
            .filter { NoticeType(rawValue: $0.type)?.style == .navigate }
            .map { $0.from }
            .filterNil()
        
        navigate.bindNext { _ in Distribution.shared.backToMainMap() }.addDisposableTo(disposeBag)
        navigate
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .flatMapLatest { LocationManager.share.location(deviceId: $0).catchErrorJustReturn(KidSate.LocationInfo()).filter{ $0.location != nil } }
            .bindTo(navigateLocationSubject)
            .addDisposableTo(disposeBag)
        
        okNotice
            .filter { NoticeType(rawValue: $0.type)?.style == .unpired }
            .map { $0.from }
            .filterNil()
            .bindNext { _ in Distribution.shared.backToTabAccount() }
            .addDisposableTo(disposeBag)
        
        let goToSeeKidInformation = confirmNotice
            .filter { NoticeType(rawValue: $0.type)?.style == .goToSee }
            .filter { NoticeType(rawValue: $0.type) == .deviceNumberChanged }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        let goToSeeFamilyMember = confirmNotice
            .filter { NoticeType(rawValue: $0.type)?.style == .goToSee }
            .filter { NoticeType(rawValue: $0.type) == .numberChanged }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        let goToSeeFriendList = confirmNotice
            .filter { NoticeType(rawValue: $0.type)?.style == .goToSee }
            .filter { NoticeType(rawValue: $0.type) == .newContact }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        Observable.merge(goToSeeKidInformation, goToSeeFamilyMember, goToSeeFriendList).bindTo(RxStore.shared.currentDeviceId).addDisposableTo(disposeBag)
        goToSeeKidInformation.bindNext { _ in Distribution.shared.propelToKidInformation() }.addDisposableTo(disposeBag)
        goToSeeFamilyMember.bindNext { _ in Distribution.shared.propelToFamilyMember() }.addDisposableTo(disposeBag)
        goToSeeFriendList.bindNext { _ in Distribution.shared.propelToFriendList() }.addDisposableTo(disposeBag)
    }
}

fileprivate func transform(alertResult: AlertResult) -> NoticeEntity? {
    if let notice = alertResult.parcel as? NoticeEntity {
        return notice
    }
    return nil
}
