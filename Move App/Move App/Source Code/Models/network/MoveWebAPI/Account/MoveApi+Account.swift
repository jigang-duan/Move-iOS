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
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: MoveApi.Account.API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        //        设备获取Access Token
        final class func getAccessToken(tokenReq: AccessTokenReq) -> Observable<UserInfo> {
            return request(.getAccessToken(tokenReq: tokenReq)).mapMoveObject(AccessToken.self).cachingToken()
        }
        //        检查用户名，邮箱，手机号码是否已被使用
        final class func isRegistered(account: String) -> Observable<Registered> {
            return request(.registered(account: account)).mapMoveObject(Registered.self)
        }
        //        帐号注册
        final class func register(userInfo: UserInfoMappable) -> Observable<UserInfo> {
            return request(.register(userInfo: userInfo)).mapMoveObject(AccessToken.self).cachingToken()
        }
        //        帐号登录
        final class func login(info: LoginInfo) -> Observable<UserInfo> {
            return request(.login(info: info)).mapMoveObject(AccessToken.self).cachingToken()
        }
        //        第三方登录
        final class func tplogin(info: TpLoginInfo) -> Observable<UserInfo> {
            return request(.tplogin(info: info)).mapMoveObject(AccessToken.self).cachingToken()
        }
        //        刷新Access Token
        final class func refreshToken() -> Observable<UserInfo> {
            return request(.refreshToken).mapMoveObject(AccessToken.self).cachingToken()
        }
        //        帐号注销
        final class func logout() -> Observable<ApiError> {
            return request(.logout).mapMoveObject(ApiError.self)
        }
        //        获取用户信息
        final class func getUserInfo(uid: String) -> Observable<UserInfoMappable> {
            return request(.getUserInfo(uid: uid)).mapMoveObject(UserInfoMappable.self)
        }
        //        设置用户信息
        final class func settingUserInfo(uid: String, info: UserInfoSetting) -> Observable<ApiError> {
            return request(.settingUserInfo(uid: uid, info: info)).mapMoveObject(ApiError.self)
        }
        //        密码找回
        final class func findPassword(info: UserFindInfo) -> Observable<ApiError> {
            return request(.findPassword(info: info)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case getAccessToken(tokenReq: AccessTokenReq)
            case registered(account: String)
            case register(userInfo: UserInfoMappable)
            case login(info: LoginInfo)
            case tplogin(info: TpLoginInfo)
            case refreshToken
            case logout
            case getUserInfo(uid: String)
            case settingUserInfo(uid: String, info: UserInfoSetting)
            case findPassword(info: UserFindInfo)
        }
        
    }
}

extension MoveApi.Account.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        switch self {
        case .refreshToken, .logout, .getUserInfo, .settingUserInfo:
            return true
        default:
            return false
        }
    }
}

extension MoveApi.Account.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL {
        switch self {
        case .getAccessToken:
             return URL(string: MoveApi.BaseURL + "/token")!
        default:
             return URL(string: MoveApi.BaseURL + "/account")!
        }
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getAccessToken:
            return ""
        case .registered(let account):
            return "/\(account)/registered"
        case .register:
            return "/register"
        case .login:
            return "/login"
        case .tplogin:
            return "/tplogin"
        case .refreshToken:
            return "/refresh_token"
        case .logout:
            return "/logout"
        case .getUserInfo(let uid):
            return "/\(uid)"
        case .settingUserInfo(let uid, _):
            return "/\(uid)"
        case .findPassword:
            return "/password"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .registered, .getUserInfo:
            return .get
        case .settingUserInfo:
            return .patch
        case .findPassword:
            return .put
        default:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .getAccessToken(let tokenReq):
            return tokenReq.toJSON()
        case .register(let userInfo):
            return userInfo.toJSON()
        case .login(let info):
            return info.toJSON()
        case  .tplogin(let info):
            return info.toJSON()
        case .settingUserInfo(_, let info):
            return info.toJSON()
        case .findPassword(let info):
            return info.toJSON()
        default:
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
        default:
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

