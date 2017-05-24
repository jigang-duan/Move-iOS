//
//  MoveApns.swift
//  Move App
//
//  Created by tcl on 2017/5/24.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper

class MoveApns{
    
    struct Apns {
        var alert: String?
        var badge: Int?
        var sound: String?
    }
}

extension MoveApns.Apns: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        alert <- map["alert"]
        badge <- map["badge"]
        sound <- map["sound"]
    }
}
