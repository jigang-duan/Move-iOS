//
//  Router.swift
//  Move App
//
//  Created by Jiang Duan on 17/2/17.
//  Copyright © 2017年 TCL Com. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    
    func popToLoginScreen() {
        self.backToDistribution(completion: {
            self.currentViewCotroller?.performSegue(withIdentifier: R.segue.distributionViewController.showLogin.identifier, sender: nil)
        })
    }
    
    func showChoseDeviceScreen() {
        self.backToDistribution(completion: {
          //  self.currentViewCotroller?.performSegue(withIdentifier: R.segue.distributionViewController.showChoseDevice.identifier, sender: nil)
        })
    }
    
    func showUserInformationScreen() {
        let toVC = R.storyboard.kidInformation().instantiateInitialViewController()!
        self.currentViewCotroller?.navigationController?.pushViewController(toVC, animated: true)
    }
}
