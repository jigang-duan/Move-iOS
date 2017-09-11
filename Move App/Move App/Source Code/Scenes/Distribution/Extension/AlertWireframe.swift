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
import CustomViews

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
    
    static func presentAlert(_ message: String, title: String? = nil, cancel: String? = nil) {
        let alertView = YHAlertView(title: title ?? "", message: message, delegate: nil, cancelButtonTitle: cancel, otherButtonTitles: ["OK"])
        alertView.visual = false
        alertView.show()
    }
    
    func prompt(_ message: String, messageTextColor: UIColor? = nil,
                title: String? = nil,
                iconURL: String? = nil,
                cancel: AlertResult, cancelActionTitle: String? = nil,
                confirm: AlertResult? = nil, confirmTitle: String? = nil) -> Observable<AlertResult> {
        
        return self.promptFor(message, messageTextColor: messageTextColor,
                              title: title, iconURL: iconURL,
                              cancelAction: cancel, cancelActionTitle: cancelActionTitle ,
                              action: confirm, actionTitle: confirmTitle)
    }
    
    func promptFor<Action : CustomStringConvertible>(_ message: String, messageTextColor: UIColor? = nil,
                   title: String? = nil,
                   iconURL: String? = nil,
                   cancelAction: Action, cancelActionTitle: String? = nil,
                   action: Action? = nil, actionTitle: String? = nil) -> Observable<Action> {
        
        let alertView = NoticeAlertControoler()
        alertView.content = message
        alertView.alertTitle = title
        alertView.iconURL = iconURL
        
        return Observable.create { observer in
            
            alertView.cancelAction = NoticeAlertControoler.Action(title: cancelActionTitle ?? cancelAction.description) {
                observer.on(.next(cancelAction))
            }
            if let _action = action {
                alertView.confirmAction = NoticeAlertControoler.Action(title: actionTitle ?? _action.description) {
                    observer.on(.next(_action))
                }
            }
            alertView.contentTextColor = messageTextColor
            alertView.show()
            
            return Disposables.create {
                alertView.dismiss()
            }
        }
    }
    
    func promptYHFor<Action : CustomStringConvertible>(_ message: String, cancelAction: Action, action: Action) -> Observable<Action> {
        return Observable.create { observer in
            let alertView = YHAlertView(title: "", message: message, delegate: nil,
                                        cancelButtonTitle: cancelAction.description, otherButtonTitles: [action.description])
            alertView.visual = false
            alertView.clickButtonBlock = { (alert, index) in
                observer.onNext(index > 0 ? action: cancelAction)
            }
            alertView.show()
            
            return Disposables.create {
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
            return R.string.localizable.id_ok()
        case .cancel:
            return R.string.localizable.id_cancel()
        case .confirm:
            return R.string.localizable.id_confirm()
        case .empty:
            return "Empty"
        }
    }
}
