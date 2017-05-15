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
        guard let groups = realm.objects(SynckeyEntity.self).filter("uid == %@", uid).first?.groups,
            let group = groups.filter({ $0.members.contains(where: { $0.id == devUid }) }).first else {
                return Observable.empty()
        }
        return Observable.collection(from: group.messages).map{ $0.filter("readStatus == 0").count }
    }
}
