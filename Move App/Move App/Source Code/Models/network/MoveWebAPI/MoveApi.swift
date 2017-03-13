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
    
    static let BaseURL: String = Configure.App.BaseURL
    
    static let apiKey: String = "key=\(Configure.App.ApiKey)"
    
    struct ApiError {
        var id: Int?
        var field: String?
        var msg: String?
    }
    
    
    static let canPopToLoginScreen = true
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

extension NSError {
    
    /// Move Api User Authorization error
    static func userAuthorizationError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "没有有效的用户权限!"]
        return NSError(domain: "com.tclcom.moveApiError", code: 1999, userInfo: userInfo)
    }
    
}
