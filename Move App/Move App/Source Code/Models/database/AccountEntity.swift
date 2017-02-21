//
//  AccountEntity.swift
//  Move App
//
//  Created by lx on 17/2/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift

class AccountEntity: Object {
    dynamic var userId: String? = nil
    dynamic var accountName: String? = nil
    dynamic var accountPassword: String? = nil
    dynamic var token: String? = nil
    dynamic  var refreshToken: String? = nil
    dynamic  var expiryAt: Date? = nil
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}
