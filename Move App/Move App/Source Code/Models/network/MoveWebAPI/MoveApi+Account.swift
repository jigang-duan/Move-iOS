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
        
        static let defaultProvider = RxMoyaProvider<MoveApi.Account.API>(
            endpointClosure: MoveApi.Account.endpointMapping,
            plugins: [MoveAccessTokenPlugin(), NetworkLoggerPlugin(verbose: true)])
        
        final class func request(_ target: MoveApi.Account.API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        
        final class func isRegistered(account: String) -> Observable<MoveApi.Registered> {
            return MoveApi.Account.request(.registered(account: account)).mapMoveObject(MoveApi.Registered.self)
        }
        
        final class func logout() -> Observable<MoveApi.ApiError> {
            return MoveApi.Account.request(.logout).mapMoveObject(MoveApi.ApiError.self)
        }
        
        enum API {
            case registered(account: String)
//            case register(info: RegisterInfo)
//            case login(info: LoginInfo)
//            case tplogin(info: TpLoginInfo)
//            case refreshToken
            case logout
        }
        
    }
}

extension MoveApi.Account.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        switch self {
        case .registered:
            return false
        case .logout:
            return true
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
        case .logout:
            return "/logout"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .registered:
            return .get
        case .logout:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .registered, .logout:
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
        case .logout:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
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

