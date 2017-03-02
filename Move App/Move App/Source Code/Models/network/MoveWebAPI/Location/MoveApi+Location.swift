//
//  MoveApi+Location.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/13.
//  Copyright © 2017年 TCL Com. All rights reserved.
//


import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    
    class Location {
        
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveApi.Location.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
//        上报位置
        final class func add(deviceId: String, locationAdd: LocationAdd) -> Observable<ApiError> {
            return request(.add(deviceId: deviceId, locationAdd: locationAdd)).mapMoveObject(ApiError.self)
        }
//        LBS定位
        final class func getByLBS(deviceId: String, locationAdd: LocationAdd) -> Observable<LocationNew> {
            return request(.getByLBS(deviceId: deviceId, locationAdd: locationAdd)).mapMoveObject(LocationNew.self)
        }
//        获取最新位置
        final class func getNew(deviceId: String) -> Observable<LocationNew> {
            return request(.getNew(deviceId: deviceId)).mapMoveObject(LocationNew.self)
        }
//        历史位置记录
        final class func getHistory(deviceId: String, locationReq: LocationReq) -> Observable<LocationHistory> {
            return request(.getHistory(deviceId: deviceId, locationReq: locationReq)).mapMoveObject(LocationHistory.self)
        }
        
        enum API {
            case add(deviceId: String, locationAdd: LocationAdd)
            case getByLBS(deviceId: String, locationAdd: LocationAdd)
            case getNew(deviceId: String)
            case getHistory(deviceId: String, locationReq: LocationReq)
        }
        
    }
}

extension MoveApi.Location.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.Location.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/v1.0/lbs")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .add(let deviceId, _):
            return "/\(deviceId)"
        case .getByLBS(let deviceId, _):
            return "/\(deviceId)"
        case .getNew(let deviceId):
            return "/\(deviceId)/location"
        case .getHistory(let deviceId, _):
            return "/\(deviceId)/locations"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .add:
            return .post
        case .getNew, .getHistory:
            return .get
        case .getByLBS:
            return .put
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .add(_, let locationAdd):
            return locationAdd.toJSON()
        case .getByLBS(_, let locationAdd):
            return locationAdd.toJSON()
        case .getNew:
            return nil
        case .getHistory(_, let locationReq):
            return locationReq.toJSON()
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .add:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.Location {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": MoveApi.apiKey])
    }
}

