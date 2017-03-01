//
//  AccountEntity.swift
//  Move App
//
//  Created by lx on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift

class MeEntity: Object {
    dynamic var id: Int = 0
    dynamic var account: AccountEntity? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class AccountEntity: Object {
    dynamic var uid: String? = nil
    
    dynamic var token : String? = nil
    dynamic  var refreshToken : String? = nil
    dynamic  var expired_at : Date? = nil
    
    dynamic var username : String? = nil
    dynamic var password : String? = nil
    
    override static func primaryKey() -> String? {
        return "uid"
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
