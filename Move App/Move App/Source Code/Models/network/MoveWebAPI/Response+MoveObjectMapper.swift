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
        if let object = Mapper<T>().map(JSONObject: try mapJSON()) {
            if let apie = object as? MoveApi.ApiError, apie.id != 0 {
                throw apie
            }
            return object
        }
        
        if let apiError = Mapper<MoveApi.ApiError>().map(JSONObject: try mapJSON()) {
            throw apiError
        }
        
        throw MoyaError.jsonMapping(self)
    }
    
    /// Maps data received from the signal into an array of objects which implement the Mappable
    /// protocol.
    /// If the conversion fails, the signal errors.
    public func mapMoveArray<T: BaseMappable>(_ type: T.Type) throws -> [T] {
        if let array = try mapJSON() as? [[String : Any]], let objects = Mapper<T>().mapArray(JSONArray: array) {
            return objects
        }
        
        if let apiError = Mapper<MoveApi.ApiError>().map(JSONObject: try mapJSON()) {
            throw apiError
        }
        
        throw MoyaError.jsonMapping(self)
    }
    
}
