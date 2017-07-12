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

extension MoveApi.ApiError {
    var isOK: Bool {
        return (id == 0) && (msg == "ok")
    }
    
    var isTokenForbidden: Bool {
        if
            let errorId = self.id, errorId == 11,
            let error_field = self.field, error_field == "access_token" {
            return true
        }
        return false
    }
    
    func tokenForbiddenError(username: String?) -> MoveApi.ApiError {
        return MoveApi.ApiError(id: 11, field: "access_token", msg: username)
    }
    
    var isTokenExpired: Bool {
        if
            let errorId = self.id, errorId == 13,
            let error_field = self.field, error_field == "access_token" {
            return true
        }
        return false
    }
}

extension NSError {
    
    /// Move Api User Authorization error
    static func userAuthorizationError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "没有有效的用户权限!"]
        return NSError(domain: "com.tclcom.moveApiError", code: 1999, userInfo: userInfo)
    }
    
    static func tokenForbiddenError() -> NSError {
        let userInfo = [NSLocalizedFailureReasonErrorKey: "Forbidden: 操作被禁止!", NSLocalizedDescriptionKey: ""]
        return NSError(domain: "com.tclcom.moveApiError", code: 1889, userInfo: userInfo)
    }
    
    static func tokenRefreshingError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "Token刷新中..."]
        return NSError(domain: "com.tclcom.moveApiError", code: 1888, userInfo: userInfo)
    }
    
    static func tokenRefreshedError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "Token刷新了！"]
        return NSError(domain: "com.tclcom.moveApiError", code: 1887, userInfo: userInfo)
    }
}
