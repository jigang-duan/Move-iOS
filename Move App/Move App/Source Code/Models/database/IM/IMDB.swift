//
//  IMDB.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/15.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift
import RxRealm


class ImDateBase {
    
    static let shared = ImDateBase()

    var realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func fetchMessages(uid: String, devUid: String) -> Observable<[MessageEntity]> {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
            return Observable.empty()
        }
        return Observable.collection(from: group.messages).map { (list) -> [MessageEntity] in list.map{ $0 } }
    }
    
    func fetchUnreadMessageCount(uid: String, devUid: String) -> Observable<Int> {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
                return Observable.empty()
        }
        return Observable.collection(from: group.messages).map{ $0.filter("readStatus == 0").count }
    }
    
    func countUnreadNoticeAtPage(uid: String) -> Int {
        guard let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups else {
            return 0
        }
        
        let counts = groups.map { group in group.notices.filter("readStatus == 0").filter{ $0.imType.atNotiicationPage }.filter{ $0.from == uid }.count }
        return counts.reduce(0, {$0+$1})
    }
    
    func fetchUnreadNoticeCount(uid: String, devUid: String) -> Observable<Int> {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
                return Observable.empty()
        }
        return Observable.collection(from: group.notices).map{ $0.filter("readStatus == 0").count }
    }
    
    func countUnreadNoticeAtPage(uid: String, devUid: String) -> Int {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
                return 0
        }
        return group.notices.filter("readStatus == 0").filter{ $0.imType.atNotiicationPage }.filter{ $0.from == uid }.count
    }
    
    func countUnreadMessage(uid: String, devUid: String) -> Int {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
                return 0
        }
        return group.messages.filter("readStatus == 0").count
    }
    
    var appVsersion: String? {
        return realm.objects(NoticeEntity.self).filter("type == %d", NoticeType.appUpdateVersion.rawValue).last?.content
    }
    
    func deviceVsersion(uid: String, devUID: String) -> String? {
        guard
            let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUID }) }).first else {
                return nil
        }
        return group.notices.filter("type == %d", NoticeType.deviceUpdateVersion.rawValue).last?.content
    }
}
