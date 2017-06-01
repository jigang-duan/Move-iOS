//
//  NotificationServer.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/1.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import UserNotifications
import Realm
import RealmSwift
import RxSwift
import RxRealm
import RxCocoa

@objc
public protocol NotificationServiceDelegate {
    @objc optional func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any])
}

class NotificationService {
    
    static let shared = NotificationService() // Singleton
    
    @IBOutlet weak var delegate: NotificationServiceDelegate?
    
    let userInfoSubject = BehaviorSubject<[AnyHashable : Any]>(value: [:])
    
    func initNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            var options = UNAuthorizationOptions()
            options.insert(UNAuthorizationOptions.alert)
            options.insert(UNAuthorizationOptions.badge)
            options.insert(UNAuthorizationOptions.sound)
            center.requestAuthorization(options: options) { (granted, error) in
                if let _error = error as? NSError {
                    Logger.error(_error)
                } else {
                    Logger.info("request authorization succeeded!")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
        } else {
            // Fallback on earlier versions
            var notificationType = UIUserNotificationType()
            notificationType.insert(UIUserNotificationType.alert)
            notificationType.insert(UIUserNotificationType.badge)
            notificationType.insert(UIUserNotificationType.sound)
            let notificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
    }
    
    func saveDeviceToken(_ token: String) {
        let realm = try! Realm()
        let entity = DeviceTokenEntity()
        entity.deviceToken = token
        try! realm.write {
            realm.add(entity, update: true)
        }
    }
    
    func fetchDeviceToken() -> Observable<String> {
        let realm = try! Realm()
        guard let token = realm.object(ofType: DeviceTokenEntity.self, forPrimaryKey: 0) else {
            return Observable.error(NSError.deviceTokenError())
        }
        
        return Observable<DeviceTokenEntity>
            .from(object: token)
            .map { entity in
                guard let deviceToken = entity.deviceToken else {
                    throw NSError.deviceTokenError()
                }
                return deviceToken
            }
    }
}

/// Extend NotificationService with `rx` proxy.
extension NotificationService: ReactiveCompatible { }

extension Reactive where Base: NotificationService {
    
    /// Reactive wrapper for `delegate`.
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy {
        return RxNotificationServiceDelegateProxy.proxyForObject(base)
    }
    
    var userInfo: ControlEvent<[AnyHashable : Any]> {
        let source = delegate
            .methodInvoked(#selector(NotificationServiceDelegate.didReceiveRemoteNotification(_:)))
            .map {
                return try castOrThrow([AnyHashable : Any].self, $0[0])
        }
        return ControlEvent(events: source)
    }
    
}

class RxNotificationServiceDelegateProxy
    : DelegateProxy
    , DelegateProxyType
, NotificationServiceDelegate {
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let service: NotificationService = castOrFatalError(object)
        service.delegate = castOptionalOrFatalError(delegate)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let service: NotificationService = castOrFatalError(object)
        return service.delegate
    }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
