//
//  MoveApi+Device.swift
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
    
    class Device {
        
        static let defaultProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.Device.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        
        final class func add(deviceId: String, addInfo: DeviceAdd) -> Observable<ApiError> {
            return request(.add(deviceId: deviceId, addInfo: addInfo)).mapMoveObject(ApiError.self)
        }
        
        final class func getDeviceList() -> Observable<DeviceGetListResp> {
            return request(.getDeviceList).mapMoveObject(DeviceGetListResp.self)
        }
        
        final class func getDeviceInfo(deviceId: String) -> Observable<DeviceInfo> {
            return request(.getDeviceInfo(deviceId: deviceId)).mapMoveObject(DeviceInfo.self)
        }
        
        final class func update(deviceId: String, updateInfo: DeviceUpdate) -> Observable<ApiError> {
            return request(.update(deviceId: deviceId, updateInfo: updateInfo)).mapMoveObject(ApiError.self)
        }
        
        final class func delete(deviceId: String) -> Observable<ApiError> {
            return request(.delete(deviceId: deviceId)).mapMoveObject(ApiError.self)
        }
        
        final class func getSetting(deviceId: String) -> Observable<DeviceSetting> {
            return request(.getSetting(deviceId: deviceId)).mapMoveObject(DeviceSetting.self)
        }
        
        final class func setting(deviceId: String, settingInfo: DeviceSetting) -> Observable<ApiError> {
            return request(.setting(deviceId: deviceId, settingInfo: settingInfo)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case add(deviceId: String, addInfo: DeviceAdd)
            case getDeviceList
            case getDeviceInfo(deviceId: String)
            case update(deviceId: String, updateInfo: DeviceUpdate)
            case delete(deviceId: String)
            case getSetting(deviceId: String)
            case setting(deviceId: String, settingInfo: DeviceSetting)
        }
        
    }
}

extension MoveApi.Device.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.Device.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/device")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .add(let deviceId, _):
            return "/\(deviceId)"
        case .getDeviceList:
            return "/list"
        case .getDeviceInfo(let deviceId):
            return "/\(deviceId)"
        case .update(let deviceId, _):
            return "/\(deviceId)"
        case .delete(let deviceId):
            return "/\(deviceId)"
        case .getSetting(let deviceId):
            return "/\(deviceId)/settings"
        case .setting(let deviceId, _):
            return "/\(deviceId)/settings"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .add:
            return .post
        case .getDeviceList, .getDeviceInfo, .getSetting:
            return .get
        case .update, .setting:
            return .put
        case .delete:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .add(_, let addInfo):
            return addInfo.toJSON()
        case .getDeviceList, .getDeviceInfo, .delete, .getSetting:
            return nil
        case .update(_, let updateInfo):
            return updateInfo.toJSON()
        case .setting(_, let settingInfo):
            return settingInfo.toJSON()
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .add:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .getDeviceList:
            return (MoveApi.DeviceGetListResp().toJSONString()?.utf8Encoded)!
        case .getDeviceInfo:
            return (MoveApi.DeviceInfo().toJSONString()?.utf8Encoded)!
        case .update:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .delete:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        case .getSetting:
            return (MoveApi.DeviceSetting().toJSONString()?.utf8Encoded)!
        case .setting:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.Device {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
}
