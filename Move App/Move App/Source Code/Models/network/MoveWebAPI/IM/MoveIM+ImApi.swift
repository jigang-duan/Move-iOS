//
//  MoveApi+IM.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/3/10.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveIM {
    
    class ImApi {
        
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveIM.ImApi.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
//        获取群组列表
        final class func getGroups() -> Observable<ImGroupList> {
            return request(.getGroups).mapMoveObject(ImGroupList.self)
        }
//        创建群组
        final class func createGroup(_ group: ImGroup) -> Observable<ImGid> {
            return request(.createGroup(group: group)).mapMoveObject(ImGid.self)
        }
//        查看群组信息
        final class func getGroupInfo(gid: ImGid) -> Observable<ImGroup> {
            return request(.getGroupInfo(gid: gid)).mapMoveObject(ImGroup.self)
        }
        
        final class func initSyncKey() -> Observable<SynckeyEntity> {
            return request(.initSyncKey).mapMoveObject(ImUserSynckey.self)
                .map({ $0.synckey  })
                .map({ SynckeyEntity(im: $0)  })
                .filterNil()
            
            //saveSynckey()
        }
        
        final class func checkSyncKey(synckey: ImCheckSynkey) -> Observable<Bool> {
            return request(.checkSyncKey(userSynckey:synckey))
                .mapMoveObject(ImSelector.self)
                .map({  ($0.selector ?? 0) > 0 })
        }
        
        final class func syncData(synckey: ImSynDatakey) -> Observable<ImSyncData> {
            return request(.syncData(synckey: synckey)).mapMoveObject(ImSyncData.self) //.saveSynData()
        }
        
        final class func sendChatMessage(messageInfo: ImMessage) -> Observable<ImMesageRsp> {
            return request(.sendChatMessage(messageInfo: messageInfo)).mapMoveObject(ImMesageRsp.self)
        }
        
        enum API {
            case getGroups
            case createGroup(group: ImGroup)
            case getGroupInfo(gid: ImGid)
            case initSyncKey
            case checkSyncKey(userSynckey:ImCheckSynkey)
            case syncData(synckey: ImSynDatakey)
            case sendChatMessage(messageInfo: ImMessage)
        }
        
    }
}

extension MoveIM.ImApi.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveIM.ImApi.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/v1.0/im")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getGroups:
            return "groups"
        case .createGroup:
            return "group"
        case .getGroupInfo(let gid):
            return "group/\(gid)"
        case .initSyncKey:
            return "init"
        case .checkSyncKey(_):
            return "check"
        case .syncData:
            return "sync"
        case .sendChatMessage(_):
            return "message"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .getGroups, .getGroupInfo, .checkSyncKey:
            return .get
        case .createGroup, .initSyncKey, .syncData, .sendChatMessage:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .createGroup(let group):
            return group.toJSON()
        case .getGroupInfo(let gid):
            return gid.toJSON()
        case .checkSyncKey(let userSynckey):
            return userSynckey.toJSON()
        case .syncData(let synckey):
            return synckey.toJSON()
        case .sendChatMessage(let messageInfo):
            return messageInfo.toJSON()
        default:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .checkSyncKey:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .getGroups:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveIM.ImApi {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Accept-Language": Locale.preferredLanguages[0],
            "Authorization": MoveApi.apiKey])
    }
}


