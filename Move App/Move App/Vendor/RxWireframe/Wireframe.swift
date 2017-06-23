//
//  Wireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

enum RetryResult {
    case retry
    case cancel
}

enum CommonResult {
    case ok
    case cancel
}

protocol Wireframe {
    func open(url: URL)
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}


class DefaultWireframe: Wireframe {
    static let sharedInstance = DefaultWireframe()
    
    func openSettings() {
        self.open(url: URL(string: UIApplicationOpenSettingsURLString)!)
    }

    func open(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

    private static func rootViewController() -> UIViewController {
        // cheating, I know
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static func presentActionSheet() {
        let sheetView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheetView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        rootViewController().present(sheetView, animated: true, completion: nil)
    }

    static func presentAlert(_ message: String) {
        let alertView = UIAlertController(title: "TCLMOVE", message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
        })
        rootViewController().present(alertView, animated: true, completion: nil)
    }

    func promptFor<Action : CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "TCLMOVE", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })

            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                    observer.on(.next(action))
                })
            }

            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)

            return Disposables.create {
                alertView.dismiss(animated:false, completion: nil)
            }
        }
    }
}


extension RetryResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        }
    }
}

extension CommonResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .ok:
            return "OK"
        case .cancel:
            return "Cancel"
        }
    }
}

extension CommonResult {
    var isOK: Bool {
        switch self {
        case .ok:
            return true
        case .cancel:
            return false
        }
    }
}
