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
    case cancel
    case ok
    case confirm
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
        if let alertView = R.storyboard.social.alert(), let currentVC = currentViewCotroller() {
            alertView.content = message
            alertView.alertTitle = title
            alertView.iconURL = iconURL
            currentVC.present(alertView, animated: true, completion: nil)
        }
    }
    
    func prompt(_ message: String, title: String? = nil, iconURL: String? = nil,
                cancel: AlertResult, confirm: AlertResult? = nil) -> Observable<AlertResult> {
        return self.promptFor(message, title: title, iconURL: iconURL, cancelAction: cancel, action: confirm)
    }
    
    func promptFor<Action : CustomStringConvertible>(_ message: String, title: String? = nil, iconURL: String? = nil,
                   cancelAction: Action, action: Action? = nil) -> Observable<Action> {
        if let alertView = R.storyboard.social.alert(),
            let currentVC = AlertWireframe.currentViewCotroller() {
            
            alertView.content = message
            alertView.alertTitle = title
            alertView.iconURL = iconURL
            return Observable.create { observer in
                alertView.cancelAction = AlertController.Action(title: cancelAction.description) {
                    observer.on(.next(cancelAction))
                }
                if let _action = action {
                    alertView.confirmAction = AlertController.Action(title: _action.description) {
                        observer.on(.next(_action))
                    }
                }
                currentVC.present(alertView, animated: true, completion: nil)
                
                return Disposables.create {
                    alertView.dismiss(animated:false, completion: nil)
                }
            }
        } else {
            return Observable.error(NSError(domain: "Unimplemented", code: -1, userInfo: nil))
        }
    }
}


extension AlertResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .ok:
            return "OK"
        case .cancel:
            return "Cancel"
        case .confirm:
            return "Confirm"
        case .empty:
            return "Empty"
        }
    }
}
