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
                let noticeType = NoticeType(rawValue: notice.type)
                let confirm = (noticeType?.style == .navigate) ? AlertResult.confirm(parcel: notice) : nil
                return AlertWireframe.shared.prompt(String(format: notice.content ?? "", kids?.nickname ?? ""),
                                                    title: noticeType?.title,
                                                    iconURL: kids?.headPortrait?.fsImageUrl,
                                                    cancel: .ok(parcel: notice),
                                                    confirm: confirm, confirmTitle: noticeType?.style.description)
            }
            .shareReplay(1)
        
        alertResult
            .map(transform)
            .filterNil()
            .flatMapLatest { notice -> Observable<NoticeEntity> in
                guard let noticeId = notice.id else {
                    return Observable.empty()
                }
                return IMManager.shared.mark(notification: noticeId).map {_ in notice }
            }
            .bindNext { notice in
                try? realm.write {
                    notice.readStatus = NoticeEntity.ReadStatus.read.rawValue
                }
            }
            .addDisposableTo(disposeBag)
        
        alertResult
            .filter { $0.isConfirm }
            .map(transform)
            .filterNil()
            .filter { NoticeType(rawValue: $0.type)?.style == .navigate }
            .map { $0.from }
            .filterNil()
            .flatMapLatest { LocationManager.share.location(deviceId: $0).catchErrorJustReturn(KidSate.LocationInfo()) }
            .bindNext { (locationInfo) in
                if let location = locationInfo.location {
                    MapUtility.openPlacemark(name: locationInfo.address ?? "", location: location)
                }
            }
            .addDisposableTo(disposeBag)
    }
}

fileprivate func transform(alertResult: AlertResult) -> NoticeEntity? {
    if let notice = alertResult.parcel as? NoticeEntity {
        return notice
    }
    return nil
}
