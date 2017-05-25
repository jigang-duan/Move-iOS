//
//  Router.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import UIKit
import RxSwift

class Distribution {
    
    static let shared = Distribution()
    
    var currentViewCotroller: UIViewController? {
        
        var result: UIViewController? = nil
        var window: UIWindow
        
        guard let _window = UIApplication.shared.keyWindow else {
            return result
        }
        window = _window
        
        if window.windowLevel != UIWindowLevelNormal {
            guard let _tmpWin =  UIApplication.shared.windows
                .filter({ $0.windowLevel == UIWindowLevelNormal })
                .first else {
                return result
            }
            window = _tmpWin
        }
        
        var nextResponder: UIResponder? = nil
        let appRootVC = window.rootViewController
        
        // 如果是present上来的appRootVC.presentedViewController 不为nil
        if let presentedVC = appRootVC?.presentedViewController {
            nextResponder = presentedVC
        } else {
            let frontView = window.subviews[0]
            nextResponder = frontView.next
        }
        
        if let tabbar = nextResponder as? UITabBarController {
            if let nav = tabbar.viewControllers?[tabbar.selectedIndex] as? UINavigationController {
                result = nav.childViewControllers.last
            }
        } else if let nav = nextResponder as? UINavigationController {
            result = nav.childViewControllers.last
        } else {
            result = nextResponder as? UIViewController
        }
        
        return result
    }
    
    func backToDistribution(completion: (() -> Void)? = nil) {
        if let tabVC = self.currentViewCotroller?.navigationController?.tabBarController {
            tabVC.dismiss(animated: false, completion: completion)
        } else if let navVC = self.currentViewCotroller?.navigationController {
            navVC.dismiss(animated: false, completion: completion)
        }
    }
    
    func backToMainMap() {
        guard let current = self.currentViewCotroller else {
            return
        }
        if (current as? MainMapController) != nil {
            return
        }
        if
            let navVC = current.navigationController,
            let tabVC = navVC.tabBarController {
            
            if tabVC.selectedIndex != 0 {
                tabVC.selectedIndex = 0
            }
            navVC.popToRootViewController(animated: true)
        }
    }
    
    func backToTabAccount() {
        guard let current = self.currentViewCotroller else {
            return
        }
        if (current as? AccountAndChoseDeviceController) != nil {
            return
        }
        popToTabAccount(current: current)
    }
    
    private func popToTabAccount(current: UIViewController) {
        if
            let navVC = current.navigationController,
            let tabVC = navVC.tabBarController {
            
            if tabVC.selectedIndex != 1 {
                tabVC.selectedIndex = 1
            }
            navVC.popToRootViewController(animated: true)
        }
    }
    
    
    var target: Target? = nil
    enum Target {
        case kidInformation
        case familyMember
        case friendList
        case chatMessage
        case updata
    }
    
    func propelToKidInformation() {
        guard let current = self.currentViewCotroller else {
            return
        }
        target = .kidInformation
        if let current = current as? AccountAndChoseDeviceController {
            current.propelToTargetController()
            return
        }
        popToTabAccount(current: current)
    }
    
    func propelToFamilyMember() {
        guard let current = self.currentViewCotroller else {
            return
        }
        target = .familyMember
        if let current = current as? AccountAndChoseDeviceController {
            current.propelToTargetController()
            return
        }
        popToTabAccount(current: current)
    }
    
    func propelToFriendList() {
        guard let current = self.currentViewCotroller else {
            return
        }
        target = .friendList
        if let current = current as? AccountAndChoseDeviceController {
            current.propelToTargetController()
            return
        }
        popToTabAccount(current: current)
    }
    
    func propelToUpdataPage() {
        guard let current = self.currentViewCotroller else {
            return
        }
        target = .updata
        if let current = current as? AccountAndChoseDeviceController {
            current.propelToTargetController()
            return
        }
        popToTabAccount(current: current)
    }

    
    func propelToChat() {
        guard let current = self.currentViewCotroller else {
            return
        }
        target = .chatMessage
        if let current = current as? MainMapController {
            current.propelToTargetController()
            return
        }
        backToMainMap()
    }
    
    
    func popToLoginScreen(_ hasWireframe: Bool = false) {
        if let current = self.currentViewCotroller, current is LoginViewController {
            return
        }
        self.backToDistribution() { [weak self] in
            self?.currentViewCotroller?.performSegue(withIdentifier: R.segue.distributionViewController.showLogin.identifier, sender: nil)
//            if hasWireframe {
//                AlertWireframe.presentAlert("Your account has been used to log in on another device or has timed out, login again.",
//                                            title: nil,
//                                            iconURL: nil,
//                                            cancel: "OK")
//            }
        }
    }
    
    func showChoseDeviceScreen() {
        self.backToDistribution(completion: {
          //  self.currentViewCotroller?.performSegue(withIdentifier: R.segue.distributionViewController.showChoseDevice, sender: nil)
        })
    }
    
    func showUserInformationScreen() {
        let toVC = R.storyboard.kidInformation().instantiateInitialViewController()!
        self.currentViewCotroller?.navigationController?.pushViewController(toVC, animated: true)
    }
    
    func showMainScreen() {
        self.backToDistribution { [weak self] in
            self?.currentViewCotroller?.performSegue(withIdentifier: R.segue.distributionViewController.showMajor.identifier, sender: nil)
        }
    }
}
