//
//  MoveApi+VerificationCode.swift
//  Move App
//
//  Created by Never on 2017/2/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    
    class VerificationCode {
        
        static let defaultProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.VerificationCode.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        
        final class func send(to: String, type: Int) -> Observable<VerificationCodeSend> {
            return request(.send(to: to,type: type)).mapMoveObject(VerificationCodeSend.self)
        }
        
        final class func verify(sid: String, vcode: String, from: String) -> Observable<ApiError> {
            return request(.verify(sid: sid, vcode: vcode, from: from)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case send(to: String, type: Int)
            case verify(sid: String, vcode: String, from: String)
        }
        
    }
}

extension MoveApi.VerificationCode.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return false
    }
}

extension MoveApi.VerificationCode.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/v1.0")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .send:
            return "vcs"
        case .verify(let sid, _, _):
            return "vcs/\(sid)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .send, .verify:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .send(let to, let type):
            return ["to":to, "type":type]
        case .verify(_, let vcode, let from):
            return ["vcode":vcode,"from":from]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .send:
            return "{\"sid\": \"abcdefg\"}".utf8Encoded
        case .verify:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.VerificationCode {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Accept-Language": Bundle.main.preferredLocalizations[0],
            "Authorization": MoveApi.apiKey])
    }
}

