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
    
    var mkSchoolTimeFirst: Bool {
        get {
            let result = UserDefaults.standard.value(forKey: mkSchoolTimeFirst_K) as? Bool
            return result ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: mkSchoolTimeFirst_K)
        }
    }
    var mkAlarmFirst: Bool {
        get {
            let result = UserDefaults.standard.value(forKey: mkAlarmFirst_K) as? Bool
            return result ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: mkAlarmFirst_K)
        }
    }

    var mkAPNFirst: Bool {
        get {
            let result = UserDefaults.standard.value(forKey: mkAPNFirst_K) as? Bool
            return result ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: mkAPNFirst_K)
        }
    }

    private let mkChatFirst_K = "mark:ChatFirst"
    private let mkSchoolTimeFirst_K = "mark:SchoolTimeFirst"
    private let mkAlarmFirst_K = "mark:AlarmFrist"
    private let mkAPNFirst_K = "mark:mkAPNFirst"
    
}
