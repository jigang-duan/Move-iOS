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


