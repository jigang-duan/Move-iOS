//
//  DataCacheManager.swift
//  Move App
//
//  Created by jiang.duan on 2017/8/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class DataCacheManager {
    
    static let shared = DataCacheManager()
    
    let realm: Realm
    
    private init() {
        realm = try! Realm()
    }
    
    func get(key: String) -> Results<DataCache> {
        return realm.objects(DataCache.self).filter("key == %@", key)
    }
    
    func set(key: String, value: String) {
        let dataCache = DataCache()
        dataCache.key = key
        dataCache.value = value
        try? realm.write {
            realm.add(dataCache, update: true)
        }
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
