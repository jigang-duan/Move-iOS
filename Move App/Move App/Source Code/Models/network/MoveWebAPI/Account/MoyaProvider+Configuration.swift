//
//  MoyaProvider+Configuration.swift
//  Move App
//
//  Created by jiang.duan on 2017/7/7.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/// These functions are default mappings to `MoyaProvider`'s properties: endpoints, requests, manager, etc.
extension MoyaProvider {

    final class func customAlamofireManager() -> Manager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }
}
