//
//  ApplicationManager.swift
//  LinkApp
//
//  Created by Jiang Duan on 17/1/3.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift
import RxCocoa
import Kingfisher
import Alamofire


/// Application Manager
class ApplicationManager {
    
    //
    // MARK: - Variable
    var disposeBag = DisposeBag()
    
    var networkReachability: NetworkReachabilityManager?
    
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
        
        // ShareSDK
        self.initShareSDK()
        
        // Bugly
        self.initBugly()
    }
    
    /// Common initialize
    func initCommon() {
        
        // Logger
        self.initLogger()
        
        // Global Appearance
        self.initGlobalAppearance()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        // Notification
        self.initNotification()
        
        // image download
        self.initImageDownloader()
        
        // NetworkReachability
        self.listenNetwor()
        
        Logger.verbose(NSHomeDirectory())
        
        // UI Debug
        let overlayClass = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type
        _ = overlayClass?.perform(NSSelectorFromString("prepareDebuggingOverlay"))
        //        let overlay = overlayClass?.perform(NSSelectorFromString("overlay")).takeUnretainedValue() as? UIWindow
        //        _ = overlay?.perform(NSSelectorFromString("toggleVisibility"))
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

extension ApplicationManager {
    
    /// initialize image downloader
    fileprivate func initImageDownloader() {
        let configuration = URLSessionConfiguration.default
        let auth = "\(MoveApi.apiKey);token=\(UserInfo.shared.accessToken.token)"
        configuration.httpAdditionalHeaders = [
            "Authorization": auth
        ]
        
        let imgManager = ImageDownloader.default
        imgManager.sessionConfiguration = configuration
        
        KingfisherManager.shared.downloader = imgManager
    }
}


// MARK: ShareSDK
extension ApplicationManager {
    
    fileprivate func initShareSDK() {
        ShareSDK.registerApp("1c4dd9ee2b8e2", activePlatforms: [
            SSDKPlatformType.typeFacebook.rawValue,
            SSDKPlatformType.typeTwitter.rawValue,
            SSDKPlatformType.typeGooglePlus.rawValue,
            ],
                             onImport: { (platform : SSDKPlatformType) in
                                switch platform
                                {
                                default:
                                    break
                                }
        }) { (platform : SSDKPlatformType, appInfo : NSMutableDictionary?) in
            
            switch platform
            {
            //设置Facebook应用信息，其中authType设置为只用SSO形式授权
            case .typeFacebook:
                appInfo?.ssdkSetupFacebook(byApiKey: "344365305959182",
                                           appSecret : "909536c55a45ca4143139006f34900db",
                                           authType : SSDKAuthTypeBoth)
            //设置Twitter应用信息
            case .typeTwitter:
                appInfo?.ssdkSetupTwitter(byConsumerKey: "YEtbencgFOdSEAqyEQQE61T94",
                                          consumerSecret : "KvPYYDdVCVZMLRr2yElRTtoCAVLbEWUYDvBfnLEG3HS3O7PQOo",
                                          redirectUri : "TCLMove://")
            //设置gooleplus应用信息
            case .typeGooglePlus:
                appInfo?.ssdkSetupGooglePlus(byClientID: "840509823178-rhb7j8vfqo00njo1o8cuph6cdge6kkej.apps.googleusercontent.com", clientSecret: "", redirectUri: "http://localhost");
            default:
                break
            }
            
        }
    }
    
}

// MARK: Bugly
extension ApplicationManager {

    fileprivate func initBugly () {
        Bugly.start(withAppId: "0e5a1986b2")
    }
}


// MARK: NetworkReachability
extension ApplicationManager {

    fileprivate func listenNetwor() {
        networkReachability = NetworkReachabilityManager()
        networkReachability?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                ProgressHUD.show(status: "Can't connect to network")
            default:
                break
            }
        }
        networkReachability?.startListening()
    }

}





