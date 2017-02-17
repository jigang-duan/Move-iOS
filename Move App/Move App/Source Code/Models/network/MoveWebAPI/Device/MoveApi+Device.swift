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
//        添加设备
        final class func add(deviceId: String, addInfo: DeviceAdd) -> Observable<ApiError> {
            return request(.add(deviceId: deviceId, addInfo: addInfo)).mapMoveObject(ApiError.self)
        }
//        加入设备群组
        final class func joinDeviceGroup(deviceId: String, joinInfo: DeviceJoinInfo) ->Observable<ApiError>{
            return request(.joinDeviceGroup(deviceId: deviceId, joinInfo: joinInfo)).mapMoveObject(ApiError.self)
        }
//        获取设备列表
        final class func getDeviceList() -> Observable<DeviceGetListResp> {
            return request(.getDeviceList).mapMoveObject(DeviceGetListResp.self)
        }
//        获取设备信息
        final class func getDeviceInfo(deviceId: String) -> Observable<DeviceInfo> {
            return request(.getDeviceInfo(deviceId: deviceId)).mapMoveObject(DeviceInfo.self)
        }
//        修改设备信息
        final class func update(deviceId: String, updateInfo: DeviceInfo) -> Observable<ApiError> {
            return request(.update(deviceId: deviceId, updateInfo: updateInfo)).mapMoveObject(ApiError.self)
        }
//        删除设备
        final class func delete(deviceId: String) -> Observable<ApiError> {
            return request(.delete(deviceId: deviceId)).mapMoveObject(ApiError.self)
        }
//        查看设备配置
        final class func getSetting(deviceId: String) -> Observable<DeviceSetting> {
            return request(.getSetting(deviceId: deviceId)).mapMoveObject(DeviceSetting.self)
        }
//        设置设备配置
        final class func setting(deviceId: String, settingInfo: DeviceSetting) -> Observable<ApiError> {
            return request(.setting(deviceId: deviceId, settingInfo: settingInfo)).mapMoveObject(ApiError.self)
        }
//        发送提醒
        final class func sendNotify(deviceId: String, sendInfo: DeviceSendNotify) -> Observable<ApiError>{
            return request(.sendNotify(deviceId: deviceId, sendInfo: sendInfo)).mapMoveObject(ApiError.self)
        }
//        上报电量
        final class func addPower(deviceId: String, power: DevicePower) -> Observable<ApiError> {
            return request(.addPower(deviceId: deviceId, power: power)).mapMoveObject(ApiError.self)
        }
//        获取电量
        final class func getPower(deviceId: String) -> Observable<DevicePower> {
            return request(.getPower(deviceId: deviceId)).mapMoveObject(DevicePower.self)
        }
        
        enum API {
            case add(deviceId: String, addInfo: DeviceAdd)
            case joinDeviceGroup(deviceId: String, joinInfo: DeviceJoinInfo)
            case getDeviceList
            case getDeviceInfo(deviceId: String)
            case update(deviceId: String, updateInfo: DeviceInfo)
            case delete(deviceId: String)
            case getSetting(deviceId: String)
            case setting(deviceId: String, settingInfo: DeviceSetting)
            case sendNotify(deviceId: String, sendInfo: DeviceSendNotify)
            case addPower(deviceId: String, power: DevicePower)
            case getPower(deviceId: String)
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
        case .joinDeviceGroup(let deviceId, _):
            return "/\(deviceId)/join"
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
        case .sendNotify(let deviceId, _):
            return "/\(deviceId)/notify"
        case .addPower(let deviceId, _):
            return "/\(deviceId)/power"
        case .getPower(let deviceId):
            return "/\(deviceId)/power"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .add, .joinDeviceGroup, .sendNotify:
            return .post
        case .getDeviceList, .getDeviceInfo, .getSetting, .getPower:
            return .get
        case .update, .setting, .addPower:
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
        case .joinDeviceGroup(_, let joinInfo):
            return joinInfo.toJSON()
        case .getDeviceList, .getDeviceInfo, .delete, .getSetting, .getPower:
            return nil
        case .update(_, let updateInfo):
            return updateInfo.toJSON()
        case .setting(_, let settingInfo):
            return settingInfo.toJSON()
        case .sendNotify(_, let sendInfo):
            return sendInfo.toJSON()
        case .addPower(_, let power):
            return power.toJSON()
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .getDeviceList:
            return ([MoveApi.DeviceInfo()].toJSONString()?.utf8Encoded)!
        case .getDeviceInfo:
            return (MoveApi.DeviceInfo().toJSONString()?.utf8Encoded)!
        case .getSetting:
            return (MoveApi.DeviceSetting().toJSONString()?.utf8Encoded)!
        default:
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
