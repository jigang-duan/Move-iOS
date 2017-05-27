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
import ObjectMapper


class AlertServer {
    
    static let share = AlertServer()
    
    let navigateLocationSubject = PublishSubject<KidSate.LocationInfo>()
    let unpiredSubject = PublishSubject<Void>()
    
    func subscribe(disposeBag: DisposeBag) {
        
        let realm = try! Realm()
        let objects = realm.objects(NoticeEntity.self)
        let notices = Observable.collection(from: objects)
            .share()
            
        let alertResult = notices
            .map { $0.filter { ($0.createDate?.isWithin1Hour)! } }
            .map { $0.filter { $0.imType.isShowPopup } }
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
            .map {_ in ()}
            .bindTo(unpiredSubject)
            .addDisposableTo(disposeBag)
        
        unpiredSubject.asObserver()
            .bindNext { Distribution.shared.backToTabAccount() }
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
        
        let goToDeviceUpdataPage = confirmNotice
            .filter { $0.imType.style == .update }
            .filter { $0.imType == .appUpdate }
            .map { $0.from }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (uid, devs) in devs.filter({ $0.user?.uid == uid }).first }
            .filterNil()
            .map{ $0.deviceId }
            .filterNil()
            .share()
        
        //Apns推送通知
        let apsNotice = NotificationService.shared.rx.userInfo
            .map{ $0 as? [String: Any] }
            .filterNil()
            .map { Mapper<MoveApns.Apns>().map(JSON: $0) }
            .filterNil()
            .share()
        
        //跳转到聊天页面
        let enterChatMessage = apsNotice
            .filter { $0.notice == .chatMessage }
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()
        
        //跳转到朋友列表页面
        let enterFriendList = apsNotice
            .filter { $0.notice == .newContact }
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()
        
        //跳转到FamilyMember页面
        let enterFamilyMenber = apsNotice
            .filter { $0.notice == .numberChanged }
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()

        
        //跳转到小孩信息页面
        let enterKidInfoPage = apsNotice
            .filter { $0.notice == .deviceNumberChanged }
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()


        //跳转到升级页面
        let enterUpdataPage = apsNotice
            .filter { $0.notice == .deviceUpdateDefeated || $0.notice == .deviceUpdateStarted || $0.notice == .deviceDownloadDefeated}
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()

        
        
        //跳转到Home页面
        let enterMainPage = apsNotice
            .filter {
                    $0.notice == .intoFence || $0.notice == .outFence||$0.notice == .lowBattery || $0.notice == .sos ||
                    $0.notice == .powered || $0.notice == .shutdown}
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()
        
        //跳转到account页面
        let enterAccountPage = apsNotice
            .filter { $0.notice == .unbound }
            .map { $0.gid }
            .filterNil()
            .withLatestFrom(RxStore.shared.deviceInfosObservable) { (gid, devs) in devs.filter{ $0.user?.gid == gid }.first }
            .filterNil()
            .map { $0.deviceId }
            .filterNil()
            .share()
        
        
        Observable.merge(goToSeeKidInformation, goToSeeFriendList, goToDeviceUpdataPage,
                         enterChatMessage,enterMainPage, enterFriendList, enterKidInfoPage, enterFamilyMenber, enterUpdataPage)
            .bindTo(RxStore.shared.currentDeviceId)
            .addDisposableTo(disposeBag)
        
        goToSeeKidInformation.bindNext { _ in Distribution.shared.propelToKidInformation() }.addDisposableTo(disposeBag)
        goToSeeFamilyMember.bindNext { _ in Distribution.shared.propelToFamilyMember() }.addDisposableTo(disposeBag)
        goToSeeFriendList.bindNext { _ in Distribution.shared.propelToFriendList() }.addDisposableTo(disposeBag)
        
        enterChatMessage.bindNext{ _ in Distribution.shared.propelToChat() }.addDisposableTo(disposeBag)
        enterFriendList.bindNext{ _ in Distribution.shared.propelToFriendList() }.addDisposableTo(disposeBag)
        enterKidInfoPage.bindNext { _ in Distribution.shared.propelToKidInformation() }.addDisposableTo(disposeBag)
        enterFamilyMenber.bindNext { _ in Distribution.shared.propelToFamilyMember() }.addDisposableTo(disposeBag)
        Observable.merge(enterUpdataPage, goToDeviceUpdataPage).bindNext{_ in Distribution.shared.propelToUpdataPage()}.addDisposableTo(disposeBag)
        enterMainPage.bindNext{_ in Distribution.shared.backToMainMap()}.addDisposableTo(disposeBag)
        enterAccountPage.bindNext{_ in Distribution.shared.backToTabAccount()}.addDisposableTo(disposeBag)
    
    }
}

fileprivate func transform(alertResult: AlertResult) -> NoticeEntity? {
    if let notice = alertResult.parcel as? NoticeEntity {
        return notice
    }
    return nil
}
