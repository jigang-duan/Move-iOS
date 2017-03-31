//
//  AppDelegate.swift
//  Move App
//
//  Created by Jiang Duan on 17/1/19.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Configure SDKs
        ApplicationManager.sharedInstance.initAllSDKs()
        
        // Init Common things
        ApplicationManager.sharedInstance.initCommon()
        
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
                
            case SSDKPlatformType.typeFacebook:
                //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                
                appInfo?.ssdkSetupFacebook(byApiKey: "344365305959182",
                                           appSecret : "909536c55a45ca4143139006f34900db",
                                           authType : SSDKAuthTypeBoth)
                
            case SSDKPlatformType.typeTwitter:
                //设置Twitter应用信息
                appInfo?.ssdkSetupTwitter(byConsumerKey: "YEtbencgFOdSEAqyEQQE61T94",
                                          consumerSecret : "KvPYYDdVCVZMLRr2yElRTtoCAVLbEWUYDvBfnLEG3HS3O7PQOo",
                                          redirectUri : "http://www.baidu.com")
            //设置gooleplus应用信息
            case SSDKPlatformType.typeGooglePlus:
                appInfo?.ssdkSetupGooglePlus(byClientID: "840509823178-rhb7j8vfqo00njo1o8cuph6cdge6kkej.apps.googleusercontent.com", clientSecret: "", redirectUri: "http://localhost");
                break
                
            default:
                break
            }
            
        }

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("\(url.absoluteString)")
        return true
    }
}

