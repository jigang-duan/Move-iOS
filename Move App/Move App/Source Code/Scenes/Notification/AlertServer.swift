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
    
    func subscribe() -> Disposable {
        let realm = try! Realm()
        let objects = realm.objects(NoticeEntity.self)
        let notices = Observable.collection(from: objects)
            .share()
            
        return notices
            .map { $0.filter({$0.readStatus == NoticeEntity.ReadStatus.unread.rawValue}).first }
            .filterNil()
            .flatMapLatest { (notice) -> Observable<AlertResult> in
                let kids = notice.owners.first?.members.filter({ $0.id == notice.from }).first
                let imageUrl = kids?.headPortrait == nil ? nil : FSManager.imageUrl(with: (kids?.headPortrait)!)
                return AlertWireframe.shared.prompt(String(format: notice.content ?? "", kids?.nickname ?? ""),
                                                    title: NoticeType(rawValue: notice.type)?.title,
                                                    iconURL: imageUrl,
                                                    cancel: .ok(parcel: notice))
            }
            .map(transform)
            .filterNil()
            .flatMapLatest({ notice in
                IMManager.shared.sendChatOp(
                    ImChatOp(msg_id: notice.id, from: notice.from, to: notice.to, gid: notice.groupId, ctime: Date(), op: .readMessage)
                )
                .map { _ in notice }
                .catchErrorJustReturn(notice)
            })
            .bindNext { notice in
                try? realm.write {
                    notice.readStatus = NoticeEntity.ReadStatus.read.rawValue
                }
            }
        
        
    }
    
    private func transform(alertResult: AlertResult) -> NoticeEntity? {
        if let notice = alertResult.parcel as? NoticeEntity {
            return notice
        }
        return nil
    }
    
}
