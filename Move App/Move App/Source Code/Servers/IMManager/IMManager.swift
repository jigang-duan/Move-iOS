//
//  IMManager.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import RxSwift
import Realm
import RealmSwift
import RxRealm


class IMManager {
    
    static let shared = IMManager()
    
    fileprivate var worker: IMWorkerProtocl!
    
    init() {
        worker = MoveApiIMWorker()
    }
}

extension IMManager {
    
    func getGroups() -> Observable<[ImGroup]> {
        return worker.getGroups()
    }
    
    func getGroupInfo(gid: String) -> Observable<ImGroup> {
        return worker.getGroupInfo(gid: gid)
    }
    
    func initSyncKey() -> Observable<MoveIM.ImUserSynckey> {
        return worker.initSyncKey()
    }
    
    func checkSyncKey(synckeyList: [ImSynckey]) -> Observable<MoveIM.ImSelector> {
        return worker.checkSyncKey(synckeyList: synckeyList)
    }
    
    func syncData() -> Observable<MoveIM.ImSyncData> {
        return worker.syncData()
    }
    
}


protocol IMWorkerProtocl {
    
    func getGroups() -> Observable<[ImGroup]>
    
    func getGroupInfo(gid: String) -> Observable<ImGroup>
    
    func initSyncKey() -> Observable<MoveIM.ImUserSynckey>
    
    func checkSyncKey(synckeyList: [ImSynckey]) -> Observable<MoveIM.ImSelector>
    
    func syncData() -> Observable<MoveIM.ImSyncData>
}


struct ImGroup {
    var gid: String?
    var topic:String?
    var profile: String?
    var owner: String?
    var flag: Int?
    var members: [ImContact]?
}

struct ImContact {
    var uid: String?
    var type: Int?
    var username: String?
    var nickname: String?
    var profile: String?
    var identity: Relation?
    var phone: String?
    var email: String?
    var time: Date?
    var sex: Int?
    var flag: Int?
    var admin: Bool?
}

struct ImSelector {
    var selector: Int?
}

struct ImSynckey {
    var key: Int?
    var value: Int?
}

struct ImUserSynckey {
    var user: ImContact?
    var synckey: [ImSynckey]?
}

struct ImMessage {
    var msg_id: String?
    var type: Int?
    var from: String?
    var to: String?
    var gid: String?
    var content: String?
    var content_type: Int?
    var content_status: Int?
    var op: Int?
    var notice: Int?
    var status: Int?
    var ctime: Date?
}



class UserSynKey {
    var uid: String? = nil
    var message = 0
    var contactMessage = 0
    var groupMessage = 0
    
}

//extension UserSynKey {
//    func invalidate() {
//        self.uid = nil
//        self.message = 0
//        self.contactMessage = 0
//        self.groupMessage = 0
//    }
//    
//    fileprivate func saveUserSyncKey() {
//        let realm = try! Realm()
//        if let usersynkey = realm.object(ofType: UserSynKeyEntity.self, forPrimaryKey: self.uid) {
//            try! realm.write {
//                usersynkey.uid = self.uid
//                usersynkey.message = self.message
//                usersynkey.contactMessage = self.contactMessage
//                usersynkey.groupMessage = self.groupMessage
//            }
//        } else {
//            let entity = UserSynKeyEntity()
//            entity.uid = self.uid
//            entity.message = self.message
//            entity.contactMessage = self.contactMessage
//            entity.groupMessage = self.groupMessage
//            try! realm.write {
//                realm.add(entity)
//            }
//        }
//    }
//}




//extension ObservableType where E == MoveIM.ImUserSynckey {
//    func saveSynckey() -> Observable<MoveIM.ImUserSynckey> {
//        return flatMap { element -> Observable<MoveIM.ImUserSynckey> in
//            
//            let realm = try! Realm()
//            if let usersynkey = realm.object(ofType: UserSynKeyEntity.self, forPrimaryKey: element.user?.uid) {
//                try! realm.write {
//                    usersynkey.uid = element.user?.uid
//                    usersynkey.message = (element.synckey?[0].value)!
//                    usersynkey.contactMessage = (element.synckey?[1].value)!
//                    usersynkey.groupMessage = (element.synckey?[2].value)!
//                }
//            } else {
//                let entity = UserSynKeyEntity()
//                entity.uid = element.user?.uid
//                entity.message = (element.synckey?[0].value)!
//                entity.contactMessage = (element.synckey?[1].value)!
//                entity.groupMessage = (element.synckey?[2].value)!
//                try! realm.write {
//                    realm.add(entity)
//                }
//            }
//
//            return Observable.just(element)
//        }
//    }
//}

