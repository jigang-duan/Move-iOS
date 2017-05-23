//
//  AppUpdate+Itunes.swift
//  Move App
//
//  Created by jiang.duan on 2017/5/23.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

import ObjectMapper
import Moya
import RxSwift
import Moya_ObjectMapper


//http://itunes.apple.com/lookup?id=appleID

class ItunesApi {
    
    static let BaseURL: String = "http://itunes.apple.com"
    
    static let appleID = "1215175812"
    static let bundleID = "com.tclcom.moveapp"
    
    final class func lookup() -> Observable<ItunesLookupItem> {
        return defaultProvider.request(.lookup(appleID: appleID)).mapMoveObject(ItunesLookup.self).map{ $0.results?.first }.filterNil()
    }
    
    enum API {
        case lookup(appleID: String)
    }
    
    static let defaultProvider = RxMoyaProvider<API>(
        plugins: [
            NetworkLoggerPlugin(verbose: true, output: Logger.reversedLog)
        ])
}


extension ItunesApi.API: TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: ItunesApi.BaseURL)!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .lookup:
            return "lookup"
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        switch self {
        case .lookup:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    var parameters: [String: Any]? {
        switch self {
        case .lookup(let appleID):
            return ["id": appleID]
        }
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding { return URLEncoding.queryString }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        switch self {
        case .lookup:
            return "{}".utf8Encoded
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task { return .request }
    
}

//    "trackViewUrl":"https://itunes.apple.com/us/app/wechat/id414478124?mt=8&uo=4",
//    "version":"6.5.8",
//    "artistName":"WeChat",
//    "trackId":1215175812,
//    "releaseDate":"2011-01-21T01:32:15Z",
//    "minimumOsVersion":"7.0",
//    "currentVersionReleaseDate":"2017-05-17T12:57:09Z"

struct ItunesLookupItem {
    var trackViewUrl: URL?
    var version: String?
    var artistName: String?
    var trackId: Int?
    var releaseDate: Date?
    var currentVersionReleaseDate: Date?
    var minimumOsVersion: String?
}

struct ItunesLookup {
    var resultCount: Int?
    var results: [ItunesLookupItem]?
}

extension ItunesLookupItem: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        trackViewUrl <- (map["trackViewUrl"], URLTransform())
        version <- map["version"]
        artistName <- map["artistName"]
        trackId <- map["trackId"]
        releaseDate <- (map["releaseDate"], ISO8601DateTransform())
        currentVersionReleaseDate <- (map["currentVersionReleaseDate"], ISO8601DateTransform())
        minimumOsVersion <- map["minimumOsVersion"]
    }
}

extension ItunesLookup: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        resultCount <- map["resultCount"]
        results <- map["results"]
    }
}
