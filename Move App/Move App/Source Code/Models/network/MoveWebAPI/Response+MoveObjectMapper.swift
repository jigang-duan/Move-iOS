//
//  Response+MoveObjectMapper.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Moya
import ObjectMapper

extension Response {
    
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    public func mapMoveObject<T: BaseMappable>(_ type: T.Type) throws -> T {
        
        guard let json = try? mapJSON() else {
            throw MoyaError.jsonMapping(self)
        }
        
        if let apiError = Mapper<MoveApi.ApiError>().map(JSONObject: json),let errId = apiError.id, errId != 0 {
            throw apiError
        }
        
        if let httpError = MoveApi.HttpError(rawValue: self.statusCode) {
            throw httpError
        }
        
        if let object = Mapper<T>().map(JSONObject: json) {
            return object
        }
        
        throw MoyaError.jsonMapping(self)
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapMoveArray<T: BaseMappable>(_ type: T.Type) throws -> [T] {
        if let apiError = Mapper<MoveApi.ApiError>().map(JSONObject: try mapJSON()) {
            throw apiError
        }
        
        if let httpError = MoveApi.HttpError(rawValue: self.statusCode) {
            throw httpError
        }
        
        if let array = try mapJSON() as? [[String : Any]], let objects = Mapper<T>().mapArray(JSONArray: array) {
            return objects
        }
        
        throw MoyaError.jsonMapping(self)
    }
    
}


/*
 4xx  客户机中出现的错误
 400  错误请求 — 请求中有语法问题，或不能满足请求。
 401  未授权 — 未授权客户机访问数据。
 402  需要付款 — 表示计费系统已有效。
 403  禁止 — 即使有授权也不需要访问。
 404  找不到 — 服务器找不到给定的资源；文档不存在。
 407  代理认证请求 — 客户机首先必须使用代理认证自身。
 415  介质类型不受支持 — 服务器拒绝服务请求，因为不支持请求实体的格式。
 5xx  服务器中出现的错误
 500  内部错误 — 因为意外情况，服务器不能完成请求。
 501  未执行 — 服务器不支持请求的工具。
 502  错误网关 — 服务器接收到来自上游服务器的无效响应。
 503  无法获得服务 — 由于临时过载或维护，服务器无法处理请求。
 */
extension MoveApi {
    
    enum HttpError: Int, Swift.Error {
        case clientRequest = 400
        case clientUnauthorized = 401
        case clientNeedPlay = 402
        case clinetBan = 403
        case clinetNotFound = 404
        case clinetProxy = 407
        case clinetMediaType = 415
        case serverInternal = 500
        case serverNotPerform = 501
        case serverGateway = 502
        case serverAccess = 503
    }
}

