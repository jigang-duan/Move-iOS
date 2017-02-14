//
//  MoveApi+ActivityRecord.swift
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
    
    class ActivityRecord {
        
        static let defaultProvider = RxMoyaProvider<API>(
            endpointClosure: MoveApi.ActivityRecord.endpointMapping,
            plugins: [
                MoveAccessTokenPlugin(),
                NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
            ])
        
        final class func request(_ target: API) -> Observable<Response> {
            return defaultProvider.request(target)
        }
//        上报活动记录
        final class func addRecord(deviceId: String, activityList: [Activity]) -> Observable<ApiError> {
            return request(.addRecord(deviceId: deviceId, activityList: activityList)).mapMoveObject(ApiError.self)
        }
//        获取活动记录
        final class func getRecord(deviceId: String, recordReq: RecordReq) -> Observable<ActivityList> {
            return request(.getRecord(deviceId: deviceId, recordReq: recordReq)).mapMoveObject(ActivityList.self)
        }
//        批量获取用户步数
        final class func getContactListStep(contactList: [Contact]) -> Observable<StepList> {
            return request(.getContactListStep(contactList: contactList)).mapMoveObject(StepList.self)
        }
//        运动点赞
        final class func sportLike(uid: String) -> Observable<ApiError> {
            return request(.sportLike(uid: uid)).mapMoveObject(ApiError.self)
        }
//        取消运动点赞
        final class func cancelSportLike(uid: String) -> Observable<ApiError> {
            return request(.cancelSportLike(uid: uid)).mapMoveObject(ApiError.self)
        }
//        获取单个用户步数(统计)
        final class func getContactStepSum(deviceId: String, stepSumReq: StepSumReq) -> Observable<Step> {
            return request(.getContactStepSum(deviceId: deviceId, stepSumReq: stepSumReq)).mapMoveObject(Step.self)
        }
//        批量获取用户分数
        final class func getContactListScore(contactList: [Contact]) -> Observable<RecordScoreList> {
            return request(.getContactListScore(contactList: contactList)).mapMoveObject(RecordScoreList.self)
        }
//        游戏点赞
        final class func gameLike(uid: String) -> Observable<ApiError> {
            return request(.gameLike(uid: uid)).mapMoveObject(ApiError.self)
        }
//        取消游戏点赞
        final class func cancelGameLike(uid: String) -> Observable<ApiError> {
            return request(.cancelGameLike(uid: uid)).mapMoveObject(ApiError.self)
        }
        
        enum API {
            case addRecord(deviceId: String, activityList: [Activity])
            case getRecord(deviceId: String, recordReq: RecordReq)
            case getContactListStep(contactList: [Contact])
            case sportLike(uid: String)
            case cancelSportLike(uid: String)
            case getContactStepSum(deviceId: String, stepSumReq: StepSumReq)
            case getContactListScore(contactList: [Contact])
            case gameLike(uid: String)
            case cancelGameLike(uid: String)
        }
        
    }
}

extension MoveApi.ActivityRecord.API: AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
}

extension MoveApi.ActivityRecord.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { return URL(string: MoveApi.BaseURL + "/activity")! }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .addRecord(let deviceId, _):
            return "/\(deviceId)"
        case .getRecord(let deviceId, _):
            return "/\(deviceId)"
        case .getContactListStep:
            return "/steps"
        case .sportLike(let uid):
            return "/step/\(uid)/like"
        case .cancelSportLike(let uid):
            return "/step/\(uid)/unlike"
        case .getContactStepSum(let deviceId, _):
            return "/step/\(deviceId)"
        case .getContactListScore:
            return "/score"
        case .gameLike(let uid):
            return "/score/\(uid)/like"
        case .cancelGameLike(let uid):
            return "/score/\(uid)/unlike"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .addRecord, .getContactListStep, .sportLike, .cancelSportLike, .getContactListScore, .gameLike, .cancelGameLike:
            return .post
        case .getRecord, .getContactStepSum:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .addRecord(_, let activityList):
            return ["activity": activityList.toJSON()]
        case .getRecord(_, let recordReq):
            return recordReq.toJSON()
        case .getContactListStep(let contactList):
            return ["contacts": contactList.toJSON()]
        case .sportLike, .cancelSportLike, .gameLike, .cancelGameLike:
            return nil
        case .getContactStepSum(_, let stepSumReq):
            return stepSumReq.toJSON()
        case .getContactListScore(let contactList):
            return ["contacts": contactList.toJSON()]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return JSONEncoding.default }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .addRecord:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        default:
            return "{\"error_id\": 0, \"error_msg\":\"ok\"}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

extension MoveApi.ActivityRecord {
    
    final class func endpointMapping(for target: API) -> Endpoint<API> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint.adding(newHTTPHeaderFields: [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "key=\(MoveApi.apiKey)"])
    }
}

