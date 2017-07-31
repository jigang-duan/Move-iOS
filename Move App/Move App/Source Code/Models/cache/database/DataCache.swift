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
    
    func get(key: String, default value: String) -> Observable<String> {
        return self.get(key: key).startWith(value)
    }
    
    func set(key: String, value: String) {
        let dataCache = DataCache()
        dataCache.key = key
        dataCache.value = value
        try? realm.write {
            realm.add(dataCache, update: true)
        }
    }
    
    func getBool(key: String) -> Observable<Bool> {
        return self.get(key: key).map{ Bool($0) }.filterNil()
    }
    
    func getBool(key: String, default value: Bool) -> Observable<Bool> {
        return self.getBool(key: key).startWith(value)
    }
    
    func set(key: String, value: Bool) {
        let dataCache = DataCache()
        dataCache.key = key
        dataCache.value = String(value)
        try? realm.write {
            realm.add(dataCache, update: true)
        }
    }
}
