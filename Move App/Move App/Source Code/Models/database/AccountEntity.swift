//
//  AccountEntity.swift
//  Move App
//
//  Created by lx on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift

enum AccountID: Int {
    case local = 0
}

class AccountEntity: Object {
    dynamic var id: Int = AccountID.local.rawValue
    dynamic var uid: String? = nil
    
    dynamic var token: String? = nil
    dynamic var refreshToken: String? = nil
    dynamic var expired_at: Date? = nil
    
    dynamic var username: String? = nil
    dynamic var password: String? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


enum DeviceTokenID: Int {
    case local = 0
}

class DeviceTokenEntity: Object {
    dynamic var tokenId: Int = DeviceTokenID.local.rawValue
    dynamic var deviceToken: String? = nil
    
    override static func primaryKey() -> String? {
        return "tokenId"
    }
}
