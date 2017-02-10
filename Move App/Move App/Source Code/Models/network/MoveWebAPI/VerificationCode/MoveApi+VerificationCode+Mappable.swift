//
//  MoveApi+VerificationCode+Mappable.swift
//  Move App
//
//  Created by Never on 2017/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import ObjectMapper


extension MoveApi {
    
    struct VerificationCodeSend {
        var sid: String?
    }
    
}

extension MoveApi.VerificationCodeSend: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        sid <- map["sid"]
    }
}
