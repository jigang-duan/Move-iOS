//
//  MoveApi+HistoryMessage+Mappable.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct GetChatReq {
        var prev: String?
        var next: String?
        var count: Int?
    }
    
    struct MessageList {
        var messages: [MessageInfo]?
    }
    
    struct MessageInfo {
        var msg_id: String?
        var from: String?
        var to: String?
        var message: Message?
        var read: Bool?
        var time: Date?
    }
    
    struct Message {
        var content: String?
        var type: String?
        var duration: Int?
    }
    
    struct NotificationList {
        var notifications: [Notification]?
    }
    
    struct NotificationInfo {
        var msg_id: String?
        var notification: Notification?
        var read: Bool?
        var time: Date?
    }
    
    struct Notification {
        var title: String?
        var body: String?
    }
}

extension MoveApi.GetChatReq: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        prev <- map["prev"]
        next <- map["next"]
        count <- map["count"]
    }
}

extension MoveApi.MessageList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        messages <- map["messages"]
    }
}

extension MoveApi.MessageInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        msg_id <- map["msg_id"]
        from <- map["from"]
        to <- map["to"]
        message <- map["message"]
        read <- map["read"]
        time <- (map["time"], DateIntTransform())
    }
}

extension MoveApi.Message: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        type <- map["type"]
        duration <- map["duration"]
    }
}

extension MoveApi.NotificationList: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        notifications <- map["notifications"]
    }
}

extension MoveApi.NotificationInfo: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        msg_id <- map["msg_id"]
        notification <- map["notification"]
        read <- map["read"]
        time <- (map["time"], DateIntTransform())
    }
}

extension MoveApi.Notification: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        body <- map["body"]
    }
}





