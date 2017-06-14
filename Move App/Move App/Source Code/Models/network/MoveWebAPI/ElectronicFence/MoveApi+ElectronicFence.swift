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
        
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveApi.ElectronicFence.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
//        添加电子围栏
        final class func addFence(deviceId: String, fenceReq: FenceReq) -> Observable<ApiError> {
            return request(.addFence(deviceId: deviceId, fenceReq: fenceReq)).mapMoveObject(ApiError.self)
        }
//        设置电子围栏
        final class func settingFence(fenceId: String, fenceReq: FenceReq) -> Observable<ApiError> {
            return request(.settingFence(fenceId: fenceId, fenceReq: fenceReq)).mapMoveObject(ApiError.self)
        }
//        获取电子围栏
        final class func getFences(deviceId: String) -> Observable<FenceList> {
            return request(.getFences(deviceId: deviceId)).mapMoveObject(FenceList.self)
        }
//        删除电子围栏
        final class func deleteFence(fenceId: String) -> Observable<ApiError> {
            return request(.deleteFence(fenceId: fenceId)).mapMoveObject(ApiError.self)
        }
        
        
        enum API {
            case addFence(deviceId: String, fenceReq: FenceReq)
            case settingFence(fenceId: String, fenceReq: FenceReq)
            case getFences(deviceId: String)
            case deleteFence(fenceId: String)
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
            return "\(deviceId)"
        case .settingFence(let fenceId, _):
            return "\(fenceId)"
        case .getFences(let deviceId):
            return "\(deviceId)"
        case .deleteFence(let fenceId):
            return "\(fenceId)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .addFence:
            return .post
        case .getFences:
            return .get
        case .settingFence:
            return .put
        case .deleteFence:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .addFence(_, let fenceReq):
            return fenceReq.toJSON()
        case .settingFence(_, let fenceReq):
            return fenceReq.toJSON()
        case .getFences, .deleteFence:
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
        case .getFences:
            return ([MoveApi.FenceInfo()].toJSONString()?.utf8Encoded)!
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.ElectronicFence.API: UseCache {
    var useCache: Bool {
        switch self {
        case .getFences:
            return true
        default:
            return false
        }
    }
}

extension MoveApi.ElectronicFence {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Accept-Language": Locale.preferredLanguages[0],
            "Authorization": MoveApi.apiKey])
    }
}
