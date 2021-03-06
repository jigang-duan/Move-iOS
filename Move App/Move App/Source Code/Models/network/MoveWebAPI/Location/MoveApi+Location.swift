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
        final class func getByLBS(deviceId: String, locationAdd: LocationAdd) -> Observable<LocationOfDevice> {
            return request(.getByLBS(deviceId: deviceId, locationAdd: locationAdd)).mapMoveObject(LocationOfDevice.self)
        }
//        获取最新位置
        final class func getNew(deviceId: String) -> Observable<LocationOfDevice> {
            return request(.getNew(deviceId: deviceId)).mapMoveObject(LocationOfDevice.self)
        }
//        批量获取多设备位置
        final class func getMultiLocations(with deviceIds: LocationMultiReq) -> Observable<Locations> {
            return request(.getMultiLocations(with: deviceIds) ).mapMoveObject(Locations.self)
        }
//        历史位置记录Electronic Fence
        final class func getHistory(deviceId: String, locationReq: LocationReq) -> Observable<LocationHistory> {
            return request(.getHistory(deviceId: deviceId, locationReq: locationReq)).mapMoveObject(LocationHistory.self)
        }
//        获取地理位置描述
        final class func getLocationRegeo(latAndLng: LocationLatAndLng) -> Observable<LocationRegeo> {
            return request(.getLocationRegeo(latAndLng: latAndLng)).mapMoveObject(LocationRegeo.self)
        }
        
        enum API {
            case add(deviceId: String, locationAdd: LocationAdd)
            case getByLBS(deviceId: String, locationAdd: LocationAdd)
            case getNew(deviceId: String)
            case getMultiLocations(with: LocationMultiReq)
            case getHistory(deviceId: String, locationReq: LocationReq)
            case getLocationRegeo(latAndLng: LocationLatAndLng)
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
            return "\(deviceId)"
        case .getByLBS(let deviceId, _):
            return "\(deviceId)"
        case .getNew(let deviceId):
            return "\(deviceId)/location"
        case .getMultiLocations:
            return "locations"
        case .getHistory(let deviceId, _):
            return "\(deviceId)/locations"
        case .getLocationRegeo(_):
            return "location/regeo"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .add, .getMultiLocations:
            return .post
        case .getNew, .getHistory, .getLocationRegeo:
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
        case .getMultiLocations(let locationMultiReq):
            return locationMultiReq.toJSON()
        case .getHistory(_, let locationReq):
            return locationReq.toJSON()
        case .getLocationRegeo(let latAndLng):
            return latAndLng.toJSON()
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getHistory, .getLocationRegeo:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
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

extension MoveApi.Location.API: UseCache {
    var useCache: Bool {
        return false
    }
}

extension MoveApi.Location {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Accept-Language": Bundle.main.preferredLocalizations[0],
            "Authorization": MoveApi.apiKey])
    }
}

