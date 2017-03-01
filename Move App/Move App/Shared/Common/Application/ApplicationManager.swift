//
//  ApplicationManager.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import IQKeyboardManager
import UserNotifications


/// Application Manager
class ApplicationManager {
    
    //
    // MARK: - Variable
    
    // singleton
    static let sharedInstance = ApplicationManager()
    
    // Global Date formatter
    lazy var globalDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'Z'"
        return dateFormatter
    }()
    
    
    //
    // MARK: Public
    
    /// initialize SDK
    func initAllSDKs() {
        
    }
    
    /// Common initialize
    func initCommon() {
        
        // Logger
        self.initLogger()
        
        // Global Appearance
        self.initGlobalAppearance()
        
        IQKeyboardManager.shared().isEnabled = true
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        // Notification
        self.initNotification()
    }
}

//
// MARK: - Private
extension ApplicationManager {
    
    // Appearance
    fileprivate func initGlobalAppearance() {
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
    }
}

// MARK:
// MARK: Logger
extension ApplicationManager {
    
    /// initialize Logger
    fileprivate func initLogger() {
        Logger.initLogger()
    }
}



