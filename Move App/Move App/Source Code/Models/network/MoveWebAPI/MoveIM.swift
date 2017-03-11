//
//  MoveIM.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/11.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

class MoveIM {
    
    static let BaseURL: String = Configure.App.BaseURL
    
    static let apiKey: String = "key=\(Configure.App.ApiKey)"
    
    struct IMError {
        var id: Int?
        var field: String?
        var msg: String?
    }
    
    
    static let canPopToLoginScreen = false
}

extension MoveIM.IMError: Swift.Error {
}

extension MoveIM.IMError: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id      <- map["error_id"]
        field   <- map["error_field"]
        msg     <- map["error_msg"]
    }
}

