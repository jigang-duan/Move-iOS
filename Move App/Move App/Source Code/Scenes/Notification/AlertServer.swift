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
            .map { $0.filter { ($0.createDate?.isWithin2Hour)! } }
            .map { $0.filter{ $0.isUnRead }.first }
            .filterNil()
            .filter { $0.imType.isShowPopup }
            .flatMapLatest { (notice) -> Observable<AlertResult> in
                let kids = notice.owners.first?.members.filter({ $0.id == notice.from }).first
                guard NoticeType(rawValue: notice.type) != nil else {
                    return Observable.empty()
                }
                let confirm = notice.imType.style.hasConfirm ? AlertResult.confirm(parcel: notice) : nil
                return AlertWireframe.shared.prompt(notice.content ?? "",
                                                    title: notice.imType.title,
                                                    iconURL: kids?.headPortrait?.fsImageUrl,
                                                    cancel: .ok(parcel: notice),
                                                    confirm: confirm, confirmTitle: notice.imType.style.description)
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
            .filter {  $0.imType.style == .navigate }
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
            .filter { $0.imType.style == .unpired }
            .map { $0.from }
            .filterNil()
            .bindNext { _ in Distribution.shared.backToTabAccount() }
            .addDisposableTo(disposeBag)
        
        let goToSeeKidInformation = confirmNotice
            .filter { $0.imType.style == .goToSee }
            .filter { $0.imType == .watchChangeSIMCard }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        let goToSeeFamilyMember = confirmNotice
            .filter { $0.imType.style == .goToSee }
            .filter { $0.imType == .familyPhoneNumberChanged }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceIdObservable)
            .share()
        
        let goToSeeFriendList = confirmNotice
            .filter { $0.imType.style == .goToSee }
            .filter { $0.imType == .kidsAddANewFriend }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        Observable.merge(goToSeeKidInformation, goToSeeFriendList).bindTo(RxStore.shared.currentDeviceId).addDisposableTo(disposeBag)
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
