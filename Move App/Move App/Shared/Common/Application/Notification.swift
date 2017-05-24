//
//  Notification.swift
//  Move App
//
//  Created by jiang.duan on 2017/2/28.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import UserNotifications


// MARK: Notification
extension ApplicationManager {
    
    /// initialize Notification
    func initNotification() {
        NotificationService.shared.initNotification()
        
    }
}

extension AppDelegate {
    
    // Register
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        Logger.verbose("notification register settings: \(notificationSettings)")
        if #available(iOS 10.0, *) {
        } else {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexToken = deviceToken.map({ String(format: "%02x", $0) }).reduce(""){ $0 + $1 }
        Logger.verbose("notification register device token: \(hexToken)")
        NotificationService.shared.saveDeviceToken(hexToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.verbose("notification register fail: \(error)")
    }
    
    // Receive
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Logger.verbose("notification Receive: \(notification)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {

        Logger.verbose("notification Receive : \(userInfo)")
        
        if application.applicationState == UIApplicationState.active{
            return //app在前台直接返回不进行任何跳转操作
        }
        NotificationService.shared.delegate?.didReceiveRemoteNotification?(userInfo)
    }
    
    
    // Handle
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        Logger.verbose("notification Handle \(identifier): \(notification)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.verbose("notification Handle \(identifier): \(notification)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.verbose("notification Handle \(identifier): \(userInfo)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.verbose("notification Handle \(identifier): \(userInfo)")
        
    }
    
}

