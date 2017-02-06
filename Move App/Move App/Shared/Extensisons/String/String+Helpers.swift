//
//  String+Helpers.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/22.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

// MARK: - Helpers
extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
