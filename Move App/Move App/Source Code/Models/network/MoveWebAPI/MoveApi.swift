//
//  MoveApi.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

class MoveApi {
    
    static let version: String = "/v1.0"
    
    static let BaseURL: String = Configure.App.BaseURL + version
    
    static let apiKey: String = Configure.App.ApiKey
    
    struct ApiError {
        var id: Int?
        var field: String?
        var msg: String?
    }
}

extension MoveApi.ApiError: Swift.Error {
}

extension MoveApi.ApiError: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id      <- map["error_id"]
        field   <- map["error_field"]
        msg     <- map["error_msg"]
    }
}

