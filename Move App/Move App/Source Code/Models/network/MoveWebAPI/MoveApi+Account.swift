//
//  MoveApi+Account.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    class Account {
        
        enum API {
            case registered(account: String)
//            case register(info: RegisterInfo)
//            case login(info: LoginInfo)
//            case tplogin(info: TpLoginInfo)
//            case refreshToken
//            case logout
        }
        
        struct AccessToken {
            var uid: String?
            var accessToken: String?
            var expiredAt: String?
        }
        
        struct Registered {
            var isRegistered: Bool?
        }
        
        struct RegisterInfo {
            var phone: String?
            var email: String?
            var profile: String?
            var nickname: String?
            var username: String?
            var password: String?
        }
        
        struct LoginInfo {
            var username: String?
            var password: String?
        }
        
        struct TpLoginInfo {
            var platform: String?
            var openif: String?
            var secret: String?
        }
        
    }
}


extension MoveApi.Account.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/account")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .registered(let account):
            return "/\(account)/registered"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .registered:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .registered:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .registered:
            return "{\"registered\": true}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.Account {
    
    final class func endpointMapping(for target: MoveApi.Account.API) -> Endpoint<MoveApi.Account.API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
}


extension MoveApi.Account.Registered: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        isRegistered <- map["registered"]
    }
}
