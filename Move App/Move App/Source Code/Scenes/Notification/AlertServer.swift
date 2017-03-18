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
    
    private var disposeBag: Disposable?
    
    func subscribe() {
        let realm = try! Realm()
        let objects = realm.objects(NoticeEntity.self)//.filter("readStatus == %d", NoticeEntity.ReadStatus.unread.rawValue)
        let notices = Observable.collection(from: objects)
            .share().debug()
            
        disposeBag = notices
            .flatMapLatest({
                Observable.just($0.filter({ $0.readStatus == NoticeEntity.ReadStatus.unread.rawValue }).first)
            })
            .filterNil()
            .flatMapLatest({ (notice) -> Observable<AlertResult> in
                AlertWireframe.shared.prompt(notice.content ?? "",title: notice.owners.first?.name, cancel: .ok(parcel: notice))
            })
            .debug()
            .bindNext({ [weak self] (alertResult) in
                switch alertResult {
                case .confirm(let parcel):
                    self?.readNotice(parcel, realm: realm)
                case .ok(let parcel):
                    self?.readNotice(parcel, realm: realm)
                default: ()
                }
            })
        Logger.debug("AlertServer subscribe")
    }
    
    func unsubscribe() {
        disposeBag?.dispose()
        Logger.debug("AlertServer unsubscribe")
    }
        
    private func readNotice(_ parcel: Any?, realm: Realm) {
        if let notice = parcel as? NoticeEntity {
            try? realm.write {
                notice.readStatus = NoticeEntity.ReadStatus.read.rawValue
            }
        }
    }
    
}
