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
        
        static let defaultProvider = RxMoyaProvider<MoveApi.VerificationCode.API>(
            endpointClosure: MoveApi.VerificationCode.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: MoveApi.VerificationCode.API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        
        final class func send(to: String) -> Observable<MoveApi.VerificationCodeSend> {
            return request(.send(to: to)).mapMoveObject(MoveApi.VerificationCodeSend.self)
        }
        
        final class func verify(sid: String, vcode: String) -> Observable<MoveApi.ApiError> {
            return request(.verify(sid: sid, vcode: vcode)).mapMoveObject(MoveApi.ApiError.self)
        }
        
        final class func delete(sid: String) -> Observable<MoveApi.ApiError> {
            return request(.delete(sid: sid)).mapMoveObject(MoveApi.ApiError.self)
        }
        
        enum API {
            case send(to: String)
            case verify(sid: String, vcode: String)
            case delete(sid: String)
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
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/vcs")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .send:
            return ""
        case .verify(let sid,_):
            return "/\(sid)"
        case .delete(let sid):
            return "/\(sid)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .send, .verify:
            return .post
        case .delete:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .send(let to):
            return ["to":to]
        case .verify(_, let vcode):
            return ["vcode":vcode]
        case .delete:
            return nil
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
        case .delete:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.VerificationCode {
    
    final class func endpointMapping(for target: MoveApi.VerificationCode.API) -> Endpoint<MoveApi.VerificationCode.API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
}

