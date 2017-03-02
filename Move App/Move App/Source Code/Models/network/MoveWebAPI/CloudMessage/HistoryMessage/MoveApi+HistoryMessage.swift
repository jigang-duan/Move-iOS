//
//  MoveApi+HistoryMessage.swift
//  Move App
//
//  Created by Wuju Zheng on 2017/2/14.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper

extension MoveApi {
    
    class HistoryMessage {
        
        static let defaultProvider = OnlineProvider<API>(
            endpointClosure: MoveApi.HistoryMessage.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
        //        查看聊天消息记录
        final class func getChatRecord(uid: String, chatReq: GetChatReq) -> Observable<MessageList> {
            return request(.getChatRecord(uid: uid, chatReq: chatReq)).mapMoveObject(MessageList.self)
        }
        //        设置消息已读状态
        final class func settingReadStatus(uid: String, msgid: String) -> Observable<ApiError> {
            return request(.settingReadStatus(uid: uid, msgid: msgid)).mapMoveObject(ApiError.self)
        }
        //        删除聊天消息
        final class func deleteByMsgid(uid: String, msgid: String) -> Observable<ApiError> {
            return request(.deleteByMsgid(uid: uid, msgid: msgid)).mapMoveObject(ApiError.self)
        }
        //        清除聊天消息
        final class func cleanMessages(uid: String) -> Observable<ApiError> {
            return request(.cleanMessages(uid: uid)).mapMoveObject(ApiError.self)
        }
        //        查看通知消息记录
        final class func getNotifications(uid: String, chatReq: GetChatReq) -> Observable<NotificationList> {
            return request(.getNotifications(uid: uid, chatReq: chatReq)).mapMoveObject(NotificationList.self)
        }
        //        设置通知已读状态
        final class func settingNotificationReadStatus(uid: String, msgid: String) -> Observable<ApiError> {
            return request(.settingNotificationReadStatus(uid: uid, msgid: msgid)).mapMoveObject(ApiError.self)
        }
        //        删除通知消息
        final class func deleteNotification(uid: String, msgid: String) -> Observable<ApiError> {
            return request(.deleteNotification(uid: uid, msgid: msgid)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case getChatRecord(uid: String, chatReq: GetChatReq)
            case settingReadStatus(uid: String, msgid: String)
            case deleteByMsgid(uid: String, msgid: String)
            case cleanMessages(uid: String)
            case getNotifications(uid: String, chatReq: GetChatReq)
            case settingNotificationReadStatus(uid: String, msgid: String)
            case deleteNotification(uid: String, msgid: String)
        }
        
    }
}

extension MoveApi.HistoryMessage.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.HistoryMessage.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/v1.0/cms")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .getChatRecord(let uid, _):
            return "/\(uid)/messages"
        case .settingReadStatus(let uid, let msgid):
            return "/\(uid)/messages/\(msgid)/read"
        case .deleteByMsgid(let uid, let msgid):
            return "/\(uid)/messages/\(msgid)"
        case .cleanMessages(let uid):
            return "/\(uid)/messages"
        case .getNotifications(let uid, _):
            return "/\(uid)/notifications"
        case .settingNotificationReadStatus(let uid, let msgid):
            return "/\(uid)/notifications/\(msgid)/read"
        case .deleteNotification(let uid, let msgid):
            return "/\(uid)/notifications/\(msgid)"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .settingReadStatus, .settingNotificationReadStatus:
            return .put
        case .getChatRecord, .getNotifications:
            return .get
        case .deleteByMsgid, .cleanMessages, .deleteNotification:
            return .delete
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .getChatRecord(_, let chatReq):
            return chatReq.toJSON()
        case .getNotifications(_, let chatReq):
            return chatReq.toJSON()
        default:
            return nil
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .getChatRecord:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.HistoryMessage {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": MoveApi.apiKey])
    }
}

