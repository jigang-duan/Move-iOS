//
//  NotificationList.swift
//  Move App
//
//  Created by lx on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift

class NotificationList: Object {
    dynamic var uid : String? = nil
    var notifications = List<NotificationEntity>()
}

class NotificationEntity: Object {
    dynamic var msg_id : String? = nil
    dynamic var read: Bool = false
    dynamic var time: Int64 = 0
    var notification = List<NotificationContextEntity>()
}

class  NotificationContextEntity: Object {
    dynamic var title : String? = nil
    dynamic var body: String? = nil
}
