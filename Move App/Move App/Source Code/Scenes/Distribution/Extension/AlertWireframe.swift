//
//  AlertWireframe.swift
//  Move App
//
//  Created by jiang.duan on 2017/3/8.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlertResult {
    case cancel(parcel: Any?)
    case ok(parcel: Any?)
    case confirm(parcel: Any?)
    case empty
}


class AlertWireframe {
    static let shared = AlertWireframe()
    
    private static func rootViewController() -> UIViewController {
        // cheating, I know
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    private static func currentViewCotroller() -> UIViewController? {
        return Distribution.shared.currentViewCotroller
    }
    
    static func presentAlert(_ message: String, title: String? = nil, iconURL: String? = nil) {
        let alertView = NoticeAlertControoler()
        alertView.content = message
        alertView.alertTitle = title
        alertView.iconURL = iconURL
        alertView.show()
        
    }
    
    func prompt(_ message: String,
                title: String? = nil,
                iconURL: String? = nil,
                cancel: AlertResult,
                confirm: AlertResult? = nil, confirmTitle: String? = nil) -> Observable<AlertResult> {
        
        return self.promptFor(message, title: title, iconURL: iconURL, cancelAction: cancel, action: confirm, actionTitle: confirmTitle)
    }
    
    func promptFor<Action : CustomStringConvertible>(_ message: String,
                   title: String? = nil,
                   iconURL: String? = nil,
                   cancelAction: Action,
                   action: Action? = nil, actionTitle: String? = nil) -> Observable<Action> {
        
        let alertView = NoticeAlertControoler()
        alertView.content = message
        alertView.alertTitle = title
        alertView.iconURL = iconURL
        
        return Observable.create { observer in
            
            alertView.cancelAction = NoticeAlertControoler.Action(title: cancelAction.description) {
                observer.on(.next(cancelAction))
            }
            if let _action = action {
                alertView.confirmAction = NoticeAlertControoler.Action(title: actionTitle ?? _action.description) {
                    observer.on(.next(_action))
                }
            }
            alertView.show()
            
            return Disposables.create {
                alertView.dismiss()
            }
        }
    }
}


extension AlertResult {
    var parcel: Any? {
        switch self {
        case .ok(let parcel):
            return parcel
        case .cancel(let parcel):
            return parcel
        case .confirm(let parcel):
            return parcel
        case .empty:
            return nil
        }
    }
}

extension AlertResult {
    var isConfirm: Bool {
        switch self {
        case .ok:
            return false
        case .cancel:
            return false
        case .confirm:
            return true
        case .empty:
            return false
        }
    }
    
    var isOK: Bool {
        switch self {
        case .ok:
            return true
        case .cancel:
            return false
        case .confirm:
            return false
        case .empty:
            return false
        }
    }
}

extension AlertResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .ok:
            return R.string.localizable.ok()
        case .cancel:
            return R.string.localizable.cancel()
        case .confirm:
            return R.string.localizable.confirm()
        case .empty:
            return "Empty"
        }
    }
}
