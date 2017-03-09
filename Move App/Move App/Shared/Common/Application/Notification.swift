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
        
        NotificationService.shared.rx.userInfo
            .asDriver()
            .drive(onNext: {
                Logger.info($0)
            })
            .addDisposableTo(disposeBag)
    }
}

extension AppDelegate {
    
    // Register
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        Logger.debug("notification register settings: \(notificationSettings)")
        if #available(iOS 10.0, *) {
        } else {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let hexToken = deviceToken.map({ String(format: "%02x", $0) }).reduce(""){ $0 + $1 }
        let tokenChars = deviceToken.description.characters.filter{$0 != Character(" ")}.filter{$0 != Character("<")}.filter{$0 != Character(">")}
        let tokenString = String(tokenChars)
        Logger.debug("notification register device token: \(hexToken)")
        NotificationService.shared.saveDeviceToken(tokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.debug("notification register fail: \(error)")
    }
    
    // Receive
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Logger.debug("notification Receive: \(notification)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Logger.debug("notification Receive : \(userInfo)")
        NotificationService.shared.delegate?.didReceiveRemoteNotification?(userInfo)
    }
    
    // Handle
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        Logger.debug("notification Handle \(identifier): \(notification)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.debug("notification Handle \(identifier): \(notification)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.debug("notification Handle \(identifier): \(userInfo)")
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        Logger.debug("notification Handle \(identifier): \(userInfo)")
        
    }
    
}
