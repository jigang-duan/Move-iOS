//
//  URL.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/12.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

extension URL {
    
    var queryParameters: [String: String]? {
        // 判断是否有参数
        guard let queryString = self.query else {
            return nil
        }
        
        var params = [String: String]()
        let urlComponents = queryString.components(separatedBy: "&")
        
        // 遍历参数
        for keyValuePair in urlComponents {
            // 生成Key/Value
            let pairComponents = keyValuePair.components(separatedBy: "=")
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            if let key = key, let value = value {
                params[key] = value
            }
        }
        
        return params
    }
    
    var urlParameters: [String: Any]? {
        // 判断是否有参数
        guard let queryString = self.query else {
            return nil
        }
        
        var params = [String: Any]()
        
        // 判断参数是单个参数还是多个参数
        if queryString.contains("&") {
            // 多个参数，分割参数
            let urlComponents = queryString.components(separatedBy: "&")
            
            // 遍历参数
            for keyValuePair in urlComponents {
                // 生成Key/Value
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first?.removingPercentEncoding
                let value = pairComponents.last?.removingPercentEncoding
                // 判断参数是否是数组
                if let key = key, let value = value {
                    // 已存在的值，生成数组
                    if let existValue = params[key] {
                        if var existValue = existValue as? [Any] {
                            existValue.append(value)
                        } else {
                            params[key] = [existValue, value]
                        }
                    } else {
                        params[key] = value
                    }
                }
            }
            
        } else {
            // 单个参数
            let pairComponents = queryString.components(separatedBy: "=")
            // 判断是否有值
            if pairComponents.count == 1 {
                return nil
            }
            
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            if let key = key, let value = value {
                params[key] = value
            }
        }
        
        return params
    }
}
