//
//  MessageHistory.swift
//  Move App
//
//  Created by lx on 17/2/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Realm
import RealmSwift

class MessagesList: Object {
    dynamic var uid : String? = nil
    var messagelist = List<MessagesEntity>()
}

class MessagesEntity: Object {
    dynamic var msg_id : String? = nil
    dynamic var from: String? = nil
    dynamic var to: String? = nil
    var message = List<MessageContextEntity>()
    dynamic var read: Bool = false
    dynamic var time : Int64 = 0
}

class MessageContextEntity: Object {
    dynamic var content : String? = nil
    dynamic var type: String? = nil
    dynamic var duration : Int64 = 0
}
