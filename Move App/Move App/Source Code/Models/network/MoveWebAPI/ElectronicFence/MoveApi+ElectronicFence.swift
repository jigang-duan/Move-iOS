//
//  MoveApi+ElectronicFence.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    
    class ElectronicFence {
        
        static let defaultProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.ElectronicFence.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        
        final class func addFence(deviceId: String, fenceList: [FenceInfo]) -> Observable<ApiError> {
            return request(.addFence(deviceId: deviceId, fenceList: fenceList)).mapMoveObject(ApiError.self)
        }
        
        final class func getFence(deviceId: String) -> Observable<FenceList> {
            return request(.getFence(deviceId: deviceId)).mapMoveObject(FenceList.self)
        }
        
        enum API {
            case addFence(deviceId: String, fenceList: [FenceInfo])
            case getFence(deviceId: String)
        }
        
    }
}

extension MoveApi.ElectronicFence.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.ElectronicFence.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/v1.0/fence")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .addFence(let deviceId, _):
            return "/\(deviceId)"
        case .getFence(let deviceId):
            return "/\(deviceId)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .addFence:
            return .post
        case .getFence:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .addFence(_, let fenceList):
            return ["fences": fenceList.toJSON()]
        case .getFence:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .addFence:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .getFence:
            return ([MoveApi.FenceInfo()].toJSONString()?.utf8Encoded)!
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.ElectronicFence {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": MoveApi.apiKey])
    }
}
