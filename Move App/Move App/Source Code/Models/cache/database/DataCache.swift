//
//  DataCache.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/28.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift
import RxRealm

class DataCache: Object {
    dynamic var key: String? = nil
    dynamic var value: String? = nil
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

class DataCacheManager {
    
    static let shared = DataCacheManager()
    
    let realm: Realm
    
    private init() {
        realm = try! Realm()
    }
    
    func get(key: String) -> Observable<String> {
        let ticker = realm.objects(DataCache.self).filter("key == %@", key)
        return Observable.collection(from: ticker).map{ $0.first?.value }.filterNil()
    }
    
    func set(key: String, value: String) {
        let ticker = DataCache()
        ticker.key = key
        ticker.value = value
        try? realm.write {
            realm.add(ticker, update: true)
        }
    }
}
