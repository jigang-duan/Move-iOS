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
        return NSError(domain: "com.tclcom.defaultError", code: 999, userInfo: userInfo)
    }
    
    
    /// JSON Mapper error
    static func jsonMapperError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "JSON Mapper error"]
        return NSError(domain: "com.clcom.defaultError", code: 998, userInfo: userInfo)
    }
    
    /// None Device Token error
    static func deviceTokenError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "None Device Token error"]
        return NSError(domain: "com.clcom.defaultError", code: 996, userInfo: userInfo)
    }
    
    var isDeviceTokenError: Bool {
        return (self.domain == "com.clcom.defaultError") && (self.code == 996)
    }
}
