//
//  Error+Default.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/9.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

extension NSError {
    
    /// Unknow error
    static func unknowError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "Unknow error"]
        return NSError(domain: "com.fe.defaultError", code: 999, userInfo: userInfo)
    }
    
    
    /// JSON Mapper Error
    static func jsonMapperError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "JSON Mapper error"]
        return NSError(domain: "com.fe.defaultError", code: 998, userInfo: userInfo)
    }
}
