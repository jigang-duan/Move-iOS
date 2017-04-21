//
//  Preferences.swift
//  Move App
//
//  Created by jiang.duan on 2017/4/21.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation

/// Application Manager
class Preferences {
    
    // singleton
    static let shared = Preferences()
    
    var mkChatFirst: Bool {
        get {
            let result = UserDefaults.standard.value(forKey: mkChatFirst_K) as? Bool
            return result ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: mkChatFirst_K)
        }
    }
    
    private let mkChatFirst_K = "mark:ChatFirst"

}
